class Appointment < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  belongs_to :doctor
  belongs_to :patient
  belongs_to :agency
  has_one    :invoice, dependent: :destroy, class_name: "Invoice"
  # has_one    :voucher, class_name: "Voucher"
  belongs_to :paymentable, polymorphic: true
  belongs_to :canceled_by, polymorphic: true
  belongs_to :voucher
  has_many :appointment_fees, dependent: :destroy, foreign_key: "appointment_id"
  has_many :doctor_return_appointments, dependent: :destroy
  has_many :judo_transactions, dependent: :destroy
  has_many :appointment_events, dependent: :destroy
  has_many :events, through: :appointment_events
  has_many :paypal_transactions, dependent: :destroy

  enum apm_type: {call_appointment: 0, in_house: 1}
  enum status: {pending: 0, on_way: 1, on_process: 2, complete: 3, assigned: 4, confirmed: 5}
  COMPLETE = 'complete'
  enum is_canceled: {normal: 0, canceled: 1}
  # enum canceled_by: {patient: 0, admin: 1}
  enum payment_status: {payment_blank: nil, payment_pending: 0, payment_denied: 1, payment_done: 2}
  enum booking_type: {bk_normal: 0, bk_auto_rescheduled: 1, bk_canceled: 2, bk_manual_resheduled: 3}

  scope :complete, -> { where("status = ? OR is_canceled = ?", statuses[:complete], is_canceleds[:canceled]) }
  scope :live, -> { where.not(status: statuses[:complete], is_canceled: is_canceleds[:canceled]) }
  scope :active, -> { where.not(status: statuses[:complete], is_canceled: is_canceleds[:canceled]) }
  scope :with_newest, -> { order(updated_at: :desc) }
  scope :created_order, -> { order(created_at: :desc) }
  scope :past_appointments_of_doctor, -> (doctor_id) { 
    where(doctor_id: doctor_id) 
    .where("is_canceled = ? OR status = ? OR (status = ? AND payment_status = ?)", 
      is_canceleds[:canceled], statuses[:complete], 
      statuses[:complete], payment_statuses[:payment_done]
    )
  }

  scope :except_invoiced_appointments_of_doctor, -> (doctor_id, appointment_returned_ids) {
    where(doctor_id: doctor_id) 
    .where("is_canceled = ? OR status = ? OR id IN (?)", 
      is_canceleds[:canceled], statuses[:complete], appointment_returned_ids
    )
  }

  ##### CALLBACKS

  # Waiting patient confirm appointment to assign doctor
  after_save :assign_doctor_worker, if: proc {|ap| ap.assigned_time_at_changed? && ap.assigned_time_at.present? && ap.doctor_id.present? && ap.assigned?}

  before_save :update_eta, if: proc {|ap| (ap.status_changed? && ap.doctor_id.present?) || (ap.assigned_time_at_changed? && ap.assigned_time_at.present?)}
  # before_save :pre_auth_payment_with_default_fee, if: proc{|ap| ap.status_changed? && ap.on_way? && ap.paymentable_type == 'PatientCreditPayment'}
  after_create :check_first_booking
  after_save :check_to_push_event

  validates :patient_id, :paymentable_id, :paymentable_type,
            :lat, :lng, :address, presence: true
  validates :lat_bill_address, :lng_bill_address, :bill_address,
            presence: true, if: "paymentable_type == 'PatientCreditPayment'"
  validates :rating, :numericality => {:greater_than_or_equal_to => 0, :message => " is an invalid rating number."}, if: proc {|ap| ap.rating.present?}
  validates :rating, :numericality => {:less_than_or_equal_to => 5, :message => " must less than or equal 5."}, if: proc {|ap| ap.rating.present?}
  validates :rating_manner, :numericality => {:greater_than_or_equal_to => 0, :message => " is an invalid rating number."}, if: proc {|ap| ap.rating_manner.present?}
  validates :rating_manner, :numericality => {:less_than_or_equal_to => 5, :message => " must less than or equal 5."}, if: proc {|ap| ap.rating_manner.present?}

  ON_PROCESS = 2
  DOCTOR_DELAY_TIME = 5
  DEFAULT_APT_DURATION = 30

  def self.modify_status
    {pending: 0, on_way: 1, on_process: 2, complete: 3, assigned: 4, confirmed: 5}
  end

  def self.booking_types
    {bk_normal: 0, bk_auto_rescheduled: 1, bk_canceled: 2, bk_manual_resheduled: 3}
  end

  def self.apm_types
    {call_appointment: 0, in_house: 1}
  end

  def as_json
    appointment_start = self.get_appointment_start
    start_time = appointment_start[:start_time]

    {
      uid:            self.id.to_i,
      doctor_id:      self.doctor_id.to_i,
      doctor_name:    self.doctor.try(:name).to_s,
      start_at:       start_time.try(:strftime, "%m/%d/%Y %H:%M:%S").to_s,
      is_canceled:    self.is_canceled == 'normal' ? false : true,
      rating:         (self.rating.to_i + self.rating_manner).to_f/2,
      total_invoice:  self.invoice.try(:total_prices).to_f
    }
  end

  def as_json_for_delayed
    {
      uid:            self.id.to_i,
      patient_id:     self.patient_id.to_i,
      start_at:       self.start_at.try(:strftime, "%m/%d/%Y %H:%M:%S").to_s,
      address:        self.address.to_s
    }
  end

  def upcoming_data
    voucher = Voucher.where(id: voucher_id).first
    voucher_code = voucher.present? ? voucher.voucher_code : ""
    total_credits = Credit.where(patient_id: patient_id, is_used: false).sum(:credit_number).to_f
    total_credits = 0 if !(total_credits > 0)
    appointment_start = self.get_appointment_start
    start_time = appointment_start[:start_time]

    data =
    {
      uid:            self.id.to_i,
      doctor_id:      self.doctor_id.to_i,
      doctor_name:    self.doctor.try(:name).to_s,
      start_at:       start_time.try(:strftime, "%m/%d/%Y - %H:%M").to_s,
      short_start_time: start_time.try(:strftime, "%H:%M").to_s,
      is_canceled:    self.is_canceled == 'normal' ? false : true,
      lat:            lat.to_f,
      lng:            lng.to_f,
      address:        address.to_s,
      voucher_code:   voucher_code.to_s,
      total_credits:  total_credits.to_f,
      appointment_fee: appointment_fee.to_f
    }
    data[:payment_method] = payment_method if payment_method.any?
    data
  end

  def past_data
    is_rated = self.rating.try(:>, 0) || self.rating_manner.try(:>, 0)
    total_invoice = number_to_currency(self.invoice.try(:total_prices), unit: "", precision: 2, separator: ".", delimiter: ",")
    voucher = Voucher.where(id: voucher_id).first
    voucher_code = voucher.present? ? voucher.voucher_code : ""

    total_credits = if complete?
      Credit.where(used_appointment_id: id, is_used: true).sum(:credit_number).to_f
    else
      Credit.where(patient_id: patient_id, is_used: false).sum(:credit_number).to_f
    end
    total_credits = 0 if !(total_credits > 0)

    data = 
    {
      uid:            self.id.to_i,
      doctor_id:      self.doctor_id.to_i,
      doctor_name:    self.doctor.try(:name).to_s,
      start_at:       self.start_at.try(:strftime, "%m/%d/%Y - %H:%M").to_s,
      is_canceled:    self.is_canceled == 'normal' ? false : true,
      lat:            lat.to_f,
      lng:            lng.to_f,
      address:        address.to_s,
      is_rated:       is_rated,
      total_invoice:  total_invoice.to_s,
      voucher_code:   voucher_code.to_s,
      total_credits:  total_credits.to_f,
      appointment_fee: appointment_fee.to_f
    }
    data[:payment_method] = payment_method if payment_method.any?
    data
  end

  def detail_as_json
    # est_time = PatientDoctor.where(doctor_id: doctor_id, patient_id: patient_id).first.try(:eta).try(:round)
    appointment_start = self.get_appointment_start
    start_time = appointment_start[:start_time]
    est_time = appointment_start[:est_time]
    start_in_second = if start_at
      (Time.zone.now - start_at).round
    else
      0
    end
    {
      uid: id.to_i,
      patient_id: patient_id.to_i,
      doctor_id: doctor_id.to_i,
      patient_full_name: patient.fullname.to_s,
      start_time: start_time.try(:strftime, "%B %d, at %H:%M").to_s,
      short_start_time: start_time.try(:strftime, "%H:%M").to_s,
      estimated_time: est_time.to_i,
      status: status.to_s,
      lat: lat.to_f,
      lng: lng.to_f,
      address: address.to_s,
      patient_phone: patient.try(:phone_number).to_s,
      start_in_second: start_in_second,
      transport: self.transport
    }
  end

  def past_data_of_doctor
    appointment_status = "cancelled" if Appointment.is_canceleds[is_canceled] == Appointment.is_canceleds[:canceled]
    appointment_status = "completed" if Appointment.statuses[status] == Appointment.statuses[:complete]
    appointment_status = "returned" if DoctorReturnAppointment.where(doctor_id: doctor_id, appointment_id: id).first.present?

    total_invoice = case appointment_status
    when "completed"
      number_to_currency(invoice.try(:total_prices), unit: "", precision: 2, separator: ".", delimiter: ",").to_f
    when "cancelled", "returned", nil
      0
    end
    {
      uid: id.to_i,
      patient_name: patient.fullname.to_s,
      created_at: created_at.strftime("%m/%d/%Y - %H:%M").to_s,
      address: address.to_s,
      status: appointment_status.to_s,
      total_invoice: total_invoice.to_f
    }
  end

  def upcoming_data_of_doctor
    {
      uid: id.to_i,
      patient_name: patient.fullname.to_s,
      created_at: created_at.strftime("%m/%d/%Y - %H:%M").to_s,
      address: address.to_s
    }
  end

  def rating_detail_json
    {
      doctor: {
        fullname: self.doctor.try(:name).to_s,
        avatar_url: self.doctor.try(:avatar).try(:url).to_s.present? ? self.doctor.try(:avatar).try(:url).to_s : "http://healthathomes.com/wp-content/uploads/bb_florida-ent-doctor.png"
      }
    }
  end

  # Remove default scope of associated models
  # def paymentable
  #   if paymentable_type == "PatientCreditPayment"
  #     PatientCreditPayment.unscoped { super }
  #   else
  #     super
  #   end
  # end

  def payment_method
    if paymentable_type == "PatientCreditPayment"
      return {
        cc_num: paymentable.try(:masking_credit_number).to_s,
        cc_type: paymentable.try(:cc_type).to_s,
        paypal_email: ""
      }
    end
    if paymentable_type == "PatientPaypalPayment"
      return {
        cc_num: "",
        cc_type: "",
        paypal_email: paymentable.try(:paypal_email).to_s
      }
    else
      return {
        cc_num: "",
        cc_type: "",
        paypal_email: ""
      }
    end
  end

  # def appointment_fee
  #   price_item_ids = PriceItem.where(is_default: true).pluck(:id)
  #   fee = AppointmentFee.where(price_item_id: price_item_ids).inject(0) { |sum, a| sum + (a.quantity * a.price_per_unit) }.to_f
  # end

  def update_eta
    puts "--------CALL UPDATE ETA---------"
    # p "=============== #{self.inspect} ================"
    # p "=============== #{self.doctor.try(:appointments)}"
    if self.status == 'pending' && self.doctor_id.present?
      self.status = 'assigned'
    end

    # get unfinished appointments of assigned doctor
    current_appointment_id = self.id
    previous_appointment = nil
    doctor_appointments = Appointment.where(doctor_id: self.doctor_id).active.order('assigned_time_at asc')
    doctor_appointment_ids = doctor_appointments.map(&:id)

    unless doctor_appointment_ids.include?(current_appointment_id)
      doctor_appointments << self
      doctor_appointments = doctor_appointments.sort_by{|a| a.assigned_time_at}
      doctor_appointment_ids = doctor_appointments.map(&:id)
    end

    # p "-------- current_appointment_id = #{current_appointment_id} ---------"
    if doctor_appointments.any? && doctor_appointment_ids.any?
      current_appointment_index = doctor_appointment_ids.index(current_appointment_id)
      # p "-------- doctor_appointment_ids = #{doctor_appointment_ids} ---------"
      # p "-------- current_appointment_index = #{current_appointment_index} ---------"

      doctor_appointments.each_with_index do |appointment, index|
        # p "-------- running_doctor_appointment_index = #{index} ---------"
        # p "-------- running_doctor_appointment= #{appointment.id} ---------"
        if (current_appointment_index.present? && index >= current_appointment_index)
          previous_appointment = doctor_appointments[index - 1] if index > 0
          if index == current_appointment_index
            self.update_appointment_time(previous_appointment.try(:id), current_appointment_id, self.status_changed?)
          else
            appointment.update_appointment_time(previous_appointment.try(:id), current_appointment_id)
          end
        end
      end
    else
      self.update_appointment_time(previous_appointment.try(:id), current_appointment_id, self.status_changed?)
    end
    puts "--------END CALL UPDATE ETA--------"
  end

  def update_appointment_time(previous_appointment_id=nil, updating_appointment_id=nil, status_change=false)
    puts "--------CALL UPDATE ETA EACH APPOINTMENT ---------"

    # Etas from doctor to patient = etas from patient to patient when doctor on_way, on_process
    appointment_transport = self.transport
    eta_doctor_to_patient = PatientDoctor.where(doctor_id: self.doctor_id, patient_id: self.patient_id, transport: appointment_transport).first.try(:eta) || 0

    previous_appointment = Appointment.find_by_id(previous_appointment_id)
    previous_patient = previous_appointment.try(:patient)
    if previous_appointment.present? && previous_patient.present?
      eta_patient_to_patient = previous_patient.calculate_eta_to_patient(self.patient_id, self.doctor_id, appointment_transport) || 0
      previous_appointment_end = previous_appointment.end_at
      if previous_appointment_end > Time.zone.now
        start_time = previous_appointment_end + eta_patient_to_patient.minutes
        eta_time = ((previous_appointment_end - Time.zone.now) / 60).round + eta_patient_to_patient.to_i
      else
        start_time = Time.zone.now + eta_doctor_to_patient.minutes
        eta_time = eta_doctor_to_patient.to_i
      end
      end_time = start_time + 30.minutes
    else
      start_time = eta_doctor_to_patient.present? ? (Time.zone.now + eta_doctor_to_patient.minutes) : Time.zone.now
      end_time = start_time + 30.minutes
      eta_time = eta_doctor_to_patient.present? ? eta_doctor_to_patient.to_i : 0
    end

    # check appointment status to update the start_at and end_at
    case Appointment.statuses[self.status]

    when Appointment.statuses[:complete]
      if status_change
        self.end_at = Time.zone.now
      end

    when Appointment.statuses[:on_process]
      if status_change
        self.update_start_at = Time.zone.now
        self.start_at = Time.zone.now
        self.end_at = Time.zone.now + 30.minutes
        self.est_end_at = self.end_at
        RemindDoctorAppointmentEndWorker.perform_at(self.est_end_at - 5.minutes, id)
      end

    when Appointment.statuses[:on_way]
      self.update_start_at = Time.zone.now
      self.confirmed_on_way_at = Time.zone.now if self.confirmed_on_way_at.nil?
      self.start_at = Time.zone.now + eta_time.minutes + self.delayed_time.to_i.minutes
      self.end_at = self.start_at + 30.minutes

    when Appointment.statuses[:confirmed]
      self.update_start_at = Time.zone.now
      self.confirmed_appointment_at = Time.zone.now if self.confirmed_appointment_at.nil?
      self.start_at = Time.zone.now + eta_time.minutes
      self.end_at = self.start_at + 30.minutes

    when Appointment.statuses[:assigned]
      self.update_start_at = Time.zone.now
      self.start_at = Time.zone.now + eta_time.minutes
      self.end_at = self.start_at + 30.minutes
    end

    self.update_start_at = Time.zone.now if self.update_start_at.nil?
    self.start_at = Time.zone.now + eta_time.minutes if self.start_at.nil?
    self.end_at = self.start_at + 30.minutes if self.end_at.nil?

    update_params = { start_at: self.start_at, end_at: self.end_at, update_start_at: self.update_start_at, 
                      confirmed_appointment_at: self.confirmed_appointment_at, confirmed_on_way_at: self.confirmed_on_way_at,
                      est_end_at: self.est_end_at }

    self.update_columns( update_params )
    # if updating_appointment_id.present? && self.id != updating_appointment_id
    #   self.update_columns(start_at: self.start_at, end_at: self.end_at, update_start_at: Time.zone.now)
    # end
    # puts "start_time = #{start_time.inspect}"
    # puts "start_time = #{start_time.inspect}"
    # puts "appointment = #{self.inspect}"
    puts "--------END CALL UPDATE ETA EACH APPOINTMENT--------"
  end

  def assign_doctor(auto_rescheduled)
    puts "start assign_doctor"
    puts "self.patient = #{self.patient.inspect}"
    doctor_id = self.patient.algorithm_optimisation_assignment(appointment_id: self.id)
    apt_status = doctor_id.nil? ? Appointment.statuses[:pending] : Appointment.statuses[:assigned]
    assigned_time_at = doctor_id.nil? ? nil : Time.zone.now
    agency_id = Doctor.find_by_id(doctor_id).try(:agency_id)
    #self.update_attributes(doctor_id: doctor_id, agency_id: agency_id, assigned_time_at: assigned_time_at, status: apt_status)
    if auto_rescheduled
      self.update_attributes(doctor_id: doctor_id, agency_id: agency_id, assigned_time_at: assigned_time_at, status: apt_status, booking_type: Appointment.booking_types[:bk_auto_rescheduled], is_canceled: Appointment.is_canceleds[:normal])
    else
      self.update_attributes(doctor_id: doctor_id, agency_id: agency_id, assigned_time_at: assigned_time_at, status: apt_status)
    end
  end

  def assign_doctor_worker
    # Reassign doctor after assign 5 minutes but not confirm
    # waiting_time = GpdqSetting.find_by_name('Time for doctor to confirm assigned appointment').try(:value)
    # waiting_time ||= 5
    # process_time = self.assigned_time_at + waiting_time.minutes
    # process_time = Time.zone.now + waiting_time.minutes unless process_time > Time.zone.now

    # Event: Doctor not yet confirmed on way when due
    event_time = self.assigned_time_at + 5.minutes
    DoctorNotConfirmWhenDueWorker.perform_at(event_time, id)

    # CheckAndReassignWorker.perform_at( process_time, self.id )
  end

  def re_assign_after_return_apt
    AssignDoctorWorker.new.perform(self.id, false)
  end

  def set_unused_voucher_code
    if voucher_id
      Voucher.where(id: voucher_id).first.update(is_used: false)
    end
  end

  # *** Must be called after create an appointment(track default price items(base fare) at the current time)
  def track_appointment_fees
    if self.appointment_fees.count == 0
      items_default = PriceItem.where(is_default: true)
      items_default.each do |item|
        self.appointment_fees.create(price_item_id: item.id, price_per_unit: item.price_per_unit, quantity: item.quantity)
        # self.appointment_fees.create(item_name: item.try(:name), price_per_unit: item.price_per_unit, quantity: item.quantity)
      end
    end
  end

  def cal_base_fare
    items_default = self.appointment_fees
    base_fare = 0
    items_default.each do |item|
      base_fare += item.price_per_unit * item.quantity
    end
    base_fare
  end

  def self.cal_appointment_fee(date)
    # Appointment fee(weekday/weekend & bank holiday) for create appointment
    apt_fee = Appointment.on_weekday(date) ? PriceList.find_by(price_type: "weekday").price.to_f : PriceList.find_by(price_type: "weekend").price.to_f
    if Appointment.on_bank_holiday(date)
      apt_fee = PriceList.find_by(price_type: "bank_fee").price.to_f if PriceList.find_by(price_type: "bank_fee").price.to_f > apt_fee
    end
    apt_fee
  end

  def total_fee
    self.invoice.try(:total_prices)
  end

  def ready_for_invoice?
    self.on_process? || self.complete? && self.normal? && !self.bk_canceled? ? true : false
  end

  # Method to do: Make a payment & Preauths
  def judo_payment(options = {method: "preauths"})#(amount, card_number, expiry_date, cvc, options = {method: "preauths", amount: 0.0})
    patient = self.patient
    payment_card = self.paymentable
    appointment_id = self.id
    puts "=================options==#{options.inspect}"
    card_number = payment_card.send :decode, payment_card.cc_num
    expiry_date = payment_card.expiry
    cvc = payment_card.send :decode, payment_card.cvc
    puts "consumer_#{patient.phone_number}"
    headers = {"API-Version" => 4.1, "Content-Type" => "application/json"}
    params = { :yourConsumerReference => "consumer_#{patient.phone_number}", 
          :yourPaymentReference => "payment_#{patient.phone_number}", 
          :yourPaymentMetaData => {},    
          :judoId => JUDOPAY[:id],      
          :cardNumber => card_number,    
          :expiryDate => expiry_date,    
          :cv2 => cvc,    
          :cardAddress => {
                :line1 => patient.address, 
                :town => "London",       
                :postCode => patient.zone.try(:name) },    
          :consumerLocation => { :latitude => patient.latitude, 
                                 :longitude => patient.longitude },
          :mobileNumber => patient.phone_number, 
          :emailAddress => patient.email
    }
    success = false
    params = params.merge(:amount => (options[:amount] || self.appointment_fee))
    puts "params = #{params.inspect}"
    puts "========"
    puts "========"

    # Using Faraday
    conn = Faraday.new(:url => "https://#{JUDOPAY[:token]}:#{JUDOPAY[:secret]}@#{JUDOPAY[:host]}/transactions") do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end
    response = conn.post do |req|
      req.url "#{options[:method]}"
      req.headers['Content-Type'] = 'application/json'
      req.headers['API-Version'] = '4.1'
      req.body = params.to_json
    end
    response = JSON.parse(response.body)
    puts "response = #{response.inspect}"
    puts "result = #{response['result']}"
    success = (response['result'] == 'Success')
    if appointment_id.nil? && !success
      puts "CASE 1"
      success
    elsif appointment_id.present? && !success
      puts "CASE 2"
      # JudoTransaction.get_and_create_transaction("consumer_#{patient.phone_number}", appointment_id)
      JudoTransaction.create_tran(response.symbolize_keys, appointment_id)
       
    else
      puts "CASE 3"
      # JudoTransaction.get_and_create_transaction("consumer_#{patient.phone_number}", appointment_id)
      JudoTransaction.create_tran(response.symbolize_keys, appointment_id)
      success
    end

    puts "------success = #{success.inspect}-------"
    success
  end

  # Method to do: Make a payment for create final invoice
  def judo_final_payment(options = {method: "payments"})
    patient = self.patient
    payment_card = self.paymentable
    appointment_id = self.id
    appointment_fee = self.appointment_fee
    # Get receipt_id of PreAuth apppointment fee
    receipt_id = JudoTransaction.find_by(appointment_id: appointment_id, payment_type: JudoTransaction.payment_types["PreAuth"], amount: appointment_fee).try(:receipt_id)
    remain_fee = options[:amount] - appointment_fee

    puts "=================options==#{options.inspect}"
    card_number = payment_card.send :decode, payment_card.cc_num
    expiry_date = payment_card.expiry
    cvc = payment_card.send :decode, payment_card.cvc
    puts "consumer_#{patient.phone_number}"

    headers = {"API-Version" => 4.1, "Content-Type" => "application/json"}
    params = { :yourConsumerReference => "consumer_#{patient.phone_number}", 
          :yourPaymentReference => "payment_#{patient.phone_number}", 
          :yourPaymentMetaData => {},    
          :judoId => JUDOPAY[:id],      
          :cardNumber => card_number,    
          :expiryDate => expiry_date,    
          :cv2 => cvc,    
          :cardAddress => {
                :line1 => patient.address, 
                :town => "London",       
                :postCode => patient.zone.try(:name) },    
          :consumerLocation => { :latitude => patient.latitude, 
                                 :longitude => patient.longitude },
          :mobileNumber => patient.phone_number, 
          :emailAddress => patient.email
    }
    success = false
    params = params.merge(:amount => remain_fee)
    puts "params = #{params.inspect}"
    puts "========"
    puts "========"

    # Using Faraday
    conn = Faraday.new(:url => "https://#{JUDOPAY[:token]}:#{JUDOPAY[:secret]}@#{JUDOPAY[:host]}/transactions") do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end

    # Collect appointment fee preauth
    params_collect = {receiptId: receipt_id, amount: appointment_fee, yourPaymentReference: "payment_#{patient.phone_number}"}
    response_collect = conn.post do |req|
      req.url "collections"
      req.headers['Content-Type'] = 'application/json'
      req.headers['API-Version'] = '4.1'
      req.body = params_collect.to_json
    end
    response_collect = JSON.parse(response_collect.body)
    JudoTransaction.create_tran(response_collect.symbolize_keys, appointment_id)
    success_collect = (response_collect['result'] == 'Success')
    puts "response_collect = #{response_collect.inspect}"
    puts "result_collect = #{response_collect['result']}"

    # Charge remaining fee(total_invoice - apppointment_fee)
    if remain_fee > 0
      response = conn.post do |req|
        req.url "#{options[:method]}"
        req.headers['Content-Type'] = 'application/json'
        req.headers['API-Version'] = '4.1'
        req.body = params.to_json
      end
      response = JSON.parse(response.body)
      puts "response = #{response.inspect}"
      puts "result = #{response['result']}"
      success = (response['result'] == 'Success')
      JudoTransaction.create_tran(response.symbolize_keys, appointment_id)
      puts "------success = #{success.inspect}-------"
    else
      puts "================="
      puts "remaining_fee <= 0"
      puts "================="
      success = true
    end
    success
  end

  def pre_auth_validate_method
    self.judo_payment({method: "preauths", amount: self.appointment_fee})
  end
  
  def pre_auth_payment_with_default_fee
    # apt_fee = Appointment.cal_appointment_fee(Time.zone.now)
    apt_fee = self.appointment_fee
    success = self.judo_payment({method: "preauths", amount: apt_fee.round(2)})
  end

  def make_payment(options = {})
    self.judo_final_payment(options)
  end

  def check_first_booking
    patient = self.patient
    if patient && !patient.got_first_booking?
      patient.update_attributes(got_first_booking: true)
    end
  end

  def check_available_booking_time
    invalid_booking_time = false
    time_now = Time.zone.now
    time_now_hour = time_now.hour
    time_now_min = time_now.min

    if time_now_hour < 8 || time_now_hour >= 23 || (time_now_hour == 22 && time_now_min >= 35)
      invalid_booking_time = true

    elsif time_now_hour == 22 && time_now_min < 35
      patient = self.try(:patient)
      doctor_id = patient.algorithm_optimisation_assignment
      if patient.present? && doctor_id.present?
        doctor = Doctor.find_by_id(doctor_id)
        pd_eta = PatientDoctor.where(doctor_id: doctor_id, patient_id: self.patient.id, transport: self.transport).first.try(:eta)
        doctor_appointments = doctor.appointments.where(status: [Appointment.statuses[:assigned], Appointment.statuses[:confirmed], Appointment.statuses[:on_way], Appointment.statuses[:on_process]], is_canceled: Appointment.is_canceleds[:normal]).order(end_at: :desc)
        last_appointment_end = doctor_appointments.first.try(:end_at)

        if doctor_appointments.any? && last_appointment_end.present? && last_appointment_end > time_now
          doctor_eta = last_appointment_end + pd_eta.to_i.minutes
        else
          doctor_eta = time_now + pd_eta.to_i.minutes
        end

        if doctor_eta.hour > 22
          invalid_booking_time = true
        end
      end
    end

    invalid_booking_time
  end

  def get_extra_fee
    if self.end_at > self.est_end_at
      fee_per_ten = Appointment.on_weekday(self.end_at) ? ExtraFee.find_by(extra_type: "weekday").price.to_f : ExtraFee.find_by(extra_type: "weekend").price.to_f
      if Appointment.on_bank_holiday(self.end_at)
        fee_per_ten = ExtraFee.find_by(extra_type: "bank_fee").price.to_f if ExtraFee.find_by(extra_type: "bank_fee").price.to_f > fee_per_ten
      end
      over_time = (self.end_at - self.est_end_at).to_f/60
      scale = over_time/10
      multi = scale.to_i < scale ? scale.to_i + 1 : scale.to_i
      fee_per_ten *= multi
      fee_per_ten.to_f
    else
      0
    end
  end

  def extend_time
    if self.est_end_at.present?
      over_time = (self.end_at - self.est_end_at).to_f/60
      scale = over_time/10
      multi = scale.to_i < scale ? scale.to_i + 1 : scale.to_i
      multi*10
    else
      0
    end
  end

  def self.on_bank_holiday(date)
    holidays = BankHoliday.pluck(:event_date)
    holidays.each do |holiday|
      if date.to_date == holiday
        return true
        break
      end
    end
    false
  end

  def self.on_weekday(date)
    date.wday > 0 && date.wday <= 5 ? true : false
  end

  ### Create appointment event method
  ### Samples use:
  # create_appointment_event(event_static_name: "Event name", reason_code_static_name: "Reason Code name")
  # create_appointment_event(event_static_name: "Event name", reason_code_static_name: "Reason Code name", options: { created_manual: false })
  def create_appointment_event(event_static_name:, reason_code_static_name: nil, options: {})
    event = Event.where(static_name: event_static_name).first
    reason_code = ReasonCode.where(static_name: reason_code_static_name).first
    new_appointment_event = {}
    if event
      reason_code_id = reason_code.try(:id)
      manual_process_event = ManualProcessEvent.where(event_id: event.id, reason_code_id: reason_code_id).first
      require_manual_options = if manual_process_event
        { require_manual_process: manual_process_event.manual_process, is_processed: false }
      else
        {}
      end

      new_appointment_event = {
        appointment_id: id,
        event_id: event.id,
        reason_code_id: reason_code_id,
        created_manual: false,
        patient_id: patient_id,
        doctor_id: doctor_id,
        standard: true
      }.merge(require_manual_options).merge(options)
    end
    appointment_event = AppointmentEvent.new(new_appointment_event)
    if appointment_event.save
      appointment_event
    else
      false
    end
  end

  ### CALLBACK USES TO SEND PUSH, SMS
  def check_to_push_event
    # Event: Dispached to doctor
    if doctor_id.present? && assigned?
      # Create appointment event and push
      appointment_event = self.create_appointment_event(event_static_name: "Dispached to doctor", options: { standard: true })
      appointment_event.send_sms_and_notification()
    end
  end

  def get_appointment_start
    appointment_start = {}
    appointment_start[:est_time] = 0
    appointment_start[:start_time] = Time.zone.now

    case Appointment.statuses[self.status]

    when Appointment.statuses[:complete]
      est_time = ((self.start_at - self.confirmed_on_way_at) / 60).round if self.start_at.present? && self.confirmed_on_way_at.present?
      est_time = 10 if est_time.present? && est_time < 10
      start_time = self.start_at if self.start_at.present?

    when Appointment.statuses[:on_process]
      est_time = ((self.start_at - self.confirmed_on_way_at) / 60).round if self.start_at.present? && self.confirmed_on_way_at.present?
      est_time = 10 if est_time.present? && est_time < 10
      start_time = self.start_at if self.start_at.present?

    when Appointment.statuses[:on_way]
      # est_time = ((self.start_at - self.update_start_at) / 60).round if self.start_at.present? && self.update_start_at.present?
      current_time = Time.zone.now
      est_time = ((self.start_at - current_time) / 60 ).round if self.start_at.present? && self.start_at > current_time
      start_time = self.start_at if self.start_at.present?

    when Appointment.statuses[:confirmed]
      est_time = ((self.start_at - self.update_start_at) / 60).round if self.start_at.present? && self.update_start_at.present?
      est_time = 10 if est_time.present? && est_time < 10
      start_time = self.update_start_at + est_time.minutes if est_time.present? && self.update_start_at.present?

    when Appointment.statuses[:assigned]
      est_time = ((self.start_at - self.update_start_at) / 60).round if self.start_at.present? && self.update_start_at.present?
      est_time = 10 if est_time.present? && est_time < 10
      start_time = Time.zone.now + est_time.minutes if est_time.present?
    end

    appointment_start[:est_time] = est_time if est_time.present?
    appointment_start[:start_time] = start_time if start_time.present?
    appointment_start
  end

  def voucher_discount
    voucher = self.try(:voucher)
    discount = number_to_currency(0.to_f, unit: "£", precision: 2, separator: ".", delimiter: ",")
    if voucher.present?
      if voucher.is_percentage?
        discount_value = voucher.try(:amount).to_f
        discount = "#{number_to_currency(discount_value, unit: "", precision: 2, separator: ".", delimiter: ",")}%"

      else
        discount = number_to_currency(voucher.try(:amount).to_f, unit: "£", precision: 2, separator: ".", delimiter: ",")
      end
    else
      patient = self.try(:patient)
      if patient.present?
        credits = patient.credits.where(is_used: false).where("expired_date >= ? ", Time.now.to_date)
        discount = number_to_currency(credits.sum(:credit_number).to_f, unit: "£", precision: 2, separator: ".", delimiter: ",")
      end
    end
    discount
  end

  def get_patient_fee
    fee = if on_way? || on_process?
      appointment_fee
    else
      0
    end
  end

end
