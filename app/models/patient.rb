class Patient < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  include TransitMode

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook]
  # geocoded_by :address
  # after_validation :geocode

  # -- Photo ----------------------------------------------------------------
  mount_uploader :avatar, PhotoUploader

  # -- Relationships --------------------------------------------------------
  has_many :patient_doctors
  has_many :doctors, through: :patient_doctors, dependent: :destroy
  belongs_to :zone, class_name: "Zone"

  has_many :locations, dependent: :destroy
  has_many :cancelled_appointments, as: :canceled_by, class_name: "Appointment"
  has_many :appointments, dependent: :destroy
  has_many :patient_credit_payments, -> { order(:created_at) }, dependent: :destroy
  has_many :patient_paypal_payments, -> { order(:created_at) }, dependent: :destroy
  # has_many :referrers, dependent: :destroy
  has_many :bill_addresses, -> { where(is_bill_address: true).order(updated_at: :desc).limit(2) } , class_name: "Location", foreign_key: "patient_id"
  has_many :patient_hold_doctors, as: :patientable, dependent: :destroy

  has_many :credits, dependent: :destroy

  # patient get his referral
  has_one :referral, class_name: "ReferralCode", foreign_key: 'sponsor_id', dependent: :destroy
  # invited patient get his referral info
  has_one :referral_info, class_name: "ReferralInfo", foreign_key: 'referred_user_id', dependent: :destroy
  # patient get all his referred patient
  has_many :referred_users, class_name: "Patient", foreign_key: "referred_by", :dependent => :destroy
  # patient get the invitor
  belongs_to :sponsor, class_name: "Patient", foreign_key: "referred_by"
  has_many :sms_systems, dependent: :destroy

  # -- Validations ----------------------------------------------------------
  # validates :first_name, :last_name, :address, :zone_id, :phone_number, presence: :true
  validates :fullname, :phone_number, presence: :true
  validates :phone_number, uniqueness: true
  validates :terms_of_service, acceptance: true, if: proc {|p| p.new_record?}
  validates :over_18, acceptance: true, if: proc {|p| p.new_record?}
  validates :platform, inclusion: { in: %w(ios android),
    message: "%{value} is not a valid platform" }, allow_blank: true

  # -- Callbacks ------------------------------------------------------------
  #after_create :save_eta
  after_create :create_referral_code
  # after_create :keep_hold_doctor_status, if: proc { |patient| patient.address.present? }
  after_create :create_referral_info, if: proc {|p| p.referred_by.present?}
  before_save :generate_auth_token, if: proc {|p| p.new_record?}
  # after_save :create_patient_doctor, if: proc {|patient| patient.new_record? || patient.zone_id_changed? || patient.address_changed?}
  after_save :update_eta_and_hold_doctor
  # after_save :keep_hold_doctor_status, if: proc {|p| p.changed_at_changed?}
  # after_save :return_doctor_to_available_list, if: proc {|p| p.changed_at_changed?} #already have a worker scheduled for runnning the same task in 'keep_hold_doctor_status' method
  def as_json_common(options={})
    {
      uid:          self.id,
      fullname:     self.try(:fullname),
      email:        self.email,
      phone_number: self.phone_number,
      auth_token:   self.try(:auth_token)
    }
  end

  def name
    self.try(:fullname)
  end

  def save_eta_with_doctor
    patient_address = self.address
    patient_id = self.id
    doctors = Doctor.joins(:doctor_zones).where("doctor_zones.zone_id = ? and latitude IS NOT NULL and longitude IS NOT NULL and doctors.available = ? and doctors.status = ?", self.zone_id, true, Doctor.statuses[:approved])
    return if doctors.blank?

    doctors.each do |doctor|
      duration = nil
      km = nil
      origin = doctor.address
      next if origin.nil?

      destinations = patient_address
      patient_appointment = self.appointments.active.where(doctor_id: doctor.id).first

      transport_methods = ['transit']
      if patient_appointment.present? && ['driving','walking'].include?(patient_appointment.transport)
        transport_methods << patient_appointment.transport
      end

      transport_methods.each do |transport_method|
        distance_record = GoogleDistanceRecord.where(origin: origin, destination: destinations, transportation: transport_method).first

        if distance_record.present?
          if !distance_record.no_result
            duration = distance_record.duration
            km = distance_record.distance
          end
        else

          result = TransitMode.call_transit(origin, destinations, transport_method)
          
          if result[0] && !result[0][:no_result]
            mm, ss = result[0][:durations].divmod(60)
            duration = (ss >= 30) ? (mm + 1).to_i : mm.to_i
            km = result[0][:km].to_f
            GoogleDistanceRecord.create(origin: origin, destination: destinations, transportation: transport_method, duration: duration, distance: km)
          else
            GoogleDistanceRecord.create(origin: origin, destination: destinations, transportation: transport_method, no_result: true)
          end
        end

        patient_doctor = PatientDoctor.find_by_patient_id_and_doctor_id_and_transport(patient_id, doctor.id, transport_method)
        if duration.present?
          if patient_doctor.nil?
            PatientDoctor.create(patient_id: patient_id, doctor_id: doctor.id, transport: transport_method, eta: duration, km: km)
          else
            patient_doctor.update_attributes(eta: duration, km: km)
          end
        else
          patient_doctor.destroy if patient_doctor.present?
        end
      end
    end

  end

  def get_available_etas
    rs = []
    available_doctor_ids = self.available_etas
    p_doctors = self.patient_doctors.where("doctor_id IN (?)", available_doctor_ids)
    p_doctors.map do |pd|
      rs << {eta: "#{pd.eta} mins"}.merge(pd.doctor.as_json_available_doctor) if pd.doctor.status == "approved" && pd.doctor.available == true
    end
    rs
  end

  def round_from_doctor_to_patient(range = nil)
    available_doctor_ids = self.available_etas

    doctors = self.patient_doctors.where("doctor_id IN (?)", available_doctor_ids)
    if range.present?
      doctors = doctors.select {|pd| pd.km <= range}
    end

    doctor_ids = doctors.map &:doctor_id
    doctor_ids
  end

  def get_available_etas_for_appt
    rs = []
    available_doctor_ids = self.available_etas
    p_doctors = self.patient_doctors.where("doctor_id IN (?)", available_doctor_ids)
    p_doctors.map do |pd|
      rs << ["#{pd.doctor.name} ETA #{pd.eta} mins", "#{pd.doctor.id}"] if pd.doctor.status == "approved" && pd.doctor.available == true
    end
    rs
  end

  def patient_zone
    self.zone.try(:name)
  end

  # Updated: Thanh - Change condition filter doctors based on doctor zone eta
  def available_etas(options = {})
    # Find available doctors
    doctors = Doctor.joins(:doctor_zones).where("doctor_zones.zone_id = ? and available = ? and latitude IS NOT NULL and longitude IS NOT NULL and doctors.status = ? and doctors.is_hold = ?", self.zone_id, true, 1, false )

    doctors_id_returned = options[:appointment_id].present? ? Appointment.find_by_id(options[:appointment_id]).doctor_return_appointments.map(&:doctor_id) : []
    doctors = doctors.select{|doctor| !doctors_id_returned.include?(doctor.id)} if doctors_id_returned.count > 0

    holding_doctor_patient = self.patient_hold_doctors.joins(:doctor).where('patient_hold_doctors.release_at IS NULL AND doctors.is_hold = ?', true).first
    holding_doctor = holding_doctor_patient.doctor if holding_doctor_patient.present?
    doctors << holding_doctor if holding_doctor.present?
  
    puts "doctors = #{doctors.inspect}"
    # # Find covered area based on ETAs
    # etas = {}
    # range = options[:range].nil? ? 60 : options[:range]
    # doctors.map do |doctor|
    #   temp_etas = doctor.doctor_zones
    #   etas[doctor.id] = temp_etas unless temp_etas.blank?
    # end
    # etas
    doctors.map(&:id)
  end

  def algorithm_optimisation_assignment(options = {})
    puts "start algorithm_optimisation_assignment"
    puts "appointment_id =  #{options[:appointment_id]}"
    available_etas_doctors = self.available_etas(appointment_id: options[:appointment_id])
    puts "available_etas_doctors = #{available_etas_doctors.inspect}"
    return nil if available_etas_doctors.blank?
    # Find ended time from scheduling doctors
    doctors = available_etas_doctors
    at_available_times = {}
    doctors.each do |dr_id|
      # ap = self.appointments.where(doctor_id: dr_id, status: [1, 2])
      # Find appoints(assigned, confirm, on_way) of doctor(dr_id)
      doctor_appointments = Doctor.find_by(id: dr_id).appointments.normal.where(status: [Appointment.statuses[:assigned], Appointment.statuses[:confirmed], Appointment.statuses[:on_way], Appointment.statuses[:on_process]]).order(assigned_time_at: :desc)
      doctor_appointments = doctor_appointments.where.not(id: options[:appointment_id]) if options[:appointment_id].present?

      # Find doctor has just assigned to appoinment
      assigned_doctor = self.appointments.active.where(doctor_id: dr_id)
      next if assigned_doctor.present?

      origin_pd_eta = PatientDoctor.where(doctor_id: dr_id, patient_id: self.id, transport: 'transit').first.try(:eta)
      if doctor_appointments.blank?
        next if origin_pd_eta.nil?

        doctor_eta = origin_pd_eta.to_i
      else
        last_appointment = doctor_appointments.first
        last_patient = last_appointment.patient
        last_appointment_end_at = last_appointment.end_at

        if last_appointment_end_at > Time.zone.now
          new_pd_eta = self.calculate_eta_to_patient(last_patient.id, dr_id)
          next if new_pd_eta.nil?

          doctor_eta = ((last_appointment_end_at - Time.zone.now) / 60 ).round + new_pd_eta.to_i
        else
          next if origin_pd_eta.nil?
          doctor_eta = origin_pd_eta.to_i
        end
      end

      at_available_times[dr_id] = doctor_eta
    end
    puts "at_available_times = #{at_available_times.inspect}"
    min_eta = at_available_times.values.min
    puts "min_eta = #{min_eta.inspect}"
    doctor_id = min_eta.blank? ? nil : at_available_times.key(min_eta)
    doctor_id
  end

  def get_min_eta
    p '=============== RUNNING get_min_eta =================='

    holding_doctor_patient = self.patient_hold_doctors.joins(:doctor).where('patient_hold_doctors.release_at IS NULL AND doctors.is_hold = ?', true).first
    holding_doctor = holding_doctor_patient.doctor if holding_doctor_patient.present?

    if holding_doctor.present?
      patient_doctor = PatientDoctor.where(doctor_id: holding_doctor.id, patient_id: self.id, transport: 'transit').first
      if patient_doctor.nil? || patient_doctor.eta.nil?
        p '=============== No PatientDoctor found - RE RUN get_min_eta_recount =================='

        min_eta_data = self.get_min_eta_recount
        return min_eta_data
      end

      min_eta = patient_doctor.eta.to_i
      at_available_times = Time.zone.now + min_eta.to_i.minutes
      doctor_appointments = Doctor.find_by(id: holding_doctor.id).appointments.normal.where(status: [Appointment.statuses[:assigned], Appointment.statuses[:confirmed], Appointment.statuses[:on_way], Appointment.statuses[:on_process]]).order(assigned_time_at: :desc)

      if doctor_appointments.blank?
        statuses = "unbooking"
      else
        last_appointment = doctor_appointments.first
        last_patient = last_appointment.patient
        last_appointment_end_at = last_appointment.end_at
        
        if last_appointment_end_at > Time.zone.now
          new_pd_eta = self.calculate_eta_to_patient(last_patient.id, holding_doctor.id) || 0
          at_available_times = last_appointment_end_at + new_pd_eta.to_i.minutes
          min_eta = ((last_appointment_end_at - Time.zone.now) / 60 ).round + new_pd_eta.to_i
        end

        statuses = last_appointment.status
      end

      min_eta_data = [holding_doctor.id, min_eta, at_available_times, statuses]

    else
      # recount min_eta when not holding any doctor
      p '=============== No doctor holding - RE RUN get_min_eta_recount =================='

      min_eta_data = self.get_min_eta_recount
    end

    min_eta_data
  end
      
  def get_min_eta_recount
    available_etas_doctors = self.available_etas
    return if available_etas_doctors.empty?
    # Find ended time from scheduling doctors
    doctors = available_etas_doctors
    at_available_times = {}
    etas = {}
    statuses = {}
    doctors.map do |dr_id|
      doctor_appointments = Doctor.find_by(id: dr_id).appointments.normal.where(status: [Appointment.statuses[:assigned], Appointment.statuses[:confirmed], Appointment.statuses[:on_way], Appointment.statuses[:on_process]]).order(assigned_time_at: :desc)
      assigned_doctor = self.appointments.active.where(doctor_id: dr_id)
      next if assigned_doctor.present?

      origin_pd_eta = PatientDoctor.where(doctor_id: dr_id, patient_id: self.id, transport: 'transit').first.try(:eta)
      if doctor_appointments.blank?
        next if origin_pd_eta.nil?

        doctor_eta = Time.zone.now + origin_pd_eta.to_i.minutes
        etas[dr_id] = origin_pd_eta.to_i
        statuses[dr_id] = "unbooking"
      else
        last_appointment = doctor_appointments.first
        last_patient = last_appointment.patient
        last_appointment_end_at = last_appointment.end_at
        
        if last_appointment_end_at > Time.zone.now
          new_pd_eta = self.calculate_eta_to_patient(last_patient.id, dr_id)
          next if new_pd_eta.nil?

          doctor_eta = last_appointment_end_at + new_pd_eta.to_i.minutes
          etas[dr_id] = ((last_appointment_end_at - Time.zone.now) / 60 ).round + new_pd_eta.to_i
        else
          next if origin_pd_eta.nil?
          doctor_eta = Time.zone.now + origin_pd_eta.to_i.minutes
          etas[dr_id] = origin_pd_eta.to_i
        end

        statuses[dr_id] = last_appointment.status
      end
      at_available_times[dr_id] = doctor_eta

    end

    min_eta = at_available_times.values.each_with_index.min
    doctor_id = min_eta.blank? ? nil : at_available_times.index(min_eta.first)
    # Return[doctor_id, min eta, arrived time, status of appoitment]
    [doctor_id, etas[doctor_id], at_available_times[doctor_id], statuses[doctor_id]]
  end

  # Calculate eta from new patient to old patients
  def calculate_eta_to_patient(new_patient_id, doctor_id=nil, transport_method=nil)

    origin = self.address

    patient = Patient.find_by_id(new_patient_id)
    destinations = patient.address
    return nil if destinations.nil?

    transport_method ||= 'transit'

    distance_record = GoogleDistanceRecord.where(origin: origin, destination: destinations, transportation: transport_method).first

    if distance_record.present?
      if !distance_record.no_result
        duration = distance_record.duration
      end
    else

      result = TransitMode.call_transit(origin, destinations, transport_method)

      duration = nil
      if result[0] && !result[0][:no_result]
        mm, ss = result[0][:durations].divmod(60)
        duration = (ss >= 30) ? (mm + 1).to_i : mm.to_i
        km = result[0][:km].to_f
        GoogleDistanceRecord.create(origin: origin, destination: destinations, transportation: transport_method, duration: duration, distance: km)
      else
        GoogleDistanceRecord.create(origin: origin, destination: destinations, transportation: transport_method, no_result: true)
      end
    end

    duration
  end

  def create_patient_doctor
    CreatePatientDoctorWorker.new.perform(self.id)
  end

  def self.new_with_session(params, session)
    super.tap do |patient|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        patient.email = data["email"] if patient.email.blank?
      end
    end
  end

  def save_billing_address(address, latitude, longitude)
    # self.locations.where(is_current_billing: true, is_bill_address: true).update_all(is_current_billing: false)
    # location = self.locations.where(is_bill_address: true, address: address, latitude: latitude, longitude: longitude).first
    # if location
    #   location.is_current_billing = true
    #   success = location.save
    # else
    #   location = self.locations.create(address: address, latitude: latitude, longitude: longitude, is_current_billing: true, is_bill_address: true)
    #   success = location.present? ? true : false
    # end
    location = self.locations.create({address: address, latitude: latitude, 
                                      longitude: longitude, is_bill_address: true,
                                      address_type: address_type
                                      })
    success = location.present? ? true : false
    {success: success, location: location.as_json}
  end

  def save_address(is_billing_address, address, latitude, longitude, address_type)
    success = false
    location = self.locations.where(is_bill_address: is_billing_address, address: address, latitude: latitude, longitude: longitude, address_type: Location.address_types[address_type]).first

    puts "location = #{location.inspect}"
    unless location.present?
      location = self.locations.create({address: address, latitude: latitude, 
                                        longitude: longitude, is_bill_address: is_billing_address,
                                        address_type: address_type
                                      })
      success = location.present? ? true : false
      # self.update_attributes(address: address)
      GeoPatient.find(self.id).save_location(self.latitude, self.longitude, address)
    else
      location.update_attributes(is_bill_address: is_billing_address, address: address, latitude: latitude, longitude: longitude, address_type: address_type, updated_at: Time.zone.now)
      success = true
    end
    {success: success, location: location.as_json}
  end

  def save_current_location(lat, lng, new_address=nil)
    # success = true
    # location = self.locations.where(address: address, latitude: latitude, longitude: longitude).first

    # unless location
    #   location = self.locations.create(address: address, latitude: latitude, longitude: longitude)
    #   success = location.errors.count == 0 ? true : false
    # end
    if (new_address.present? && self.address != new_address) || (new_address.nil? && lat.present? && lng.present? && (self.latitude != lat || self.longitude != lng))
      GeoPatient.find(self.id).save_location(lat, lng, new_address)
    end

    self.reload.update_attributes(changed_at: Time.zone.now)
    {success: true}
  end

  def find_doctor_around(lat, lng, new_address=nil, range=nil)
    time = 0

    if (new_address.present? && self.address != new_address) || (new_address.nil? && lat.present? && lng.present? && (self.latitude != lat || self.longitude != lng))
      GeoPatient.find_by_id(self.id).save_location(lat, lng, new_address, range)
    end

    begin
      # to get new location for patient
      self.reload
      # doctor_ids = patient.round_from_doctor_to_patient(range)
      # doctors = []
      # doctor_ids.map do |dr_id|
      #   doctors << Doctor.find(dr_id).as_json
      # end
      doctors = Doctor.where("latitude IS NOT NULL and longitude IS NOT NULL and doctors.status = ? and doctors.is_hold = ?", Doctor.statuses[:approved], false)
      holding_doctor_patient = self.patient_hold_doctors.joins(:doctor).where('patient_hold_doctors.release_at IS NULL AND doctors.is_hold = ?', true).first
      holding_doctor = holding_doctor_patient.doctor if holding_doctor_patient.present?
      doctors << holding_doctor if holding_doctor.present?
      doctors = doctors.map(&:as_json)
      doctors

    rescue
      time += 1
      retry if time < 2
      []
    end
  end

  def keep_hold_doctor_status
    p '------------ holding doctor for patient'
    # KeepHoldDoctorStatusWorker.new.perform(self.id)
    doctor_id = self.algorithm_optimisation_assignment
    if doctor_id
      doctor = Doctor.find_by_id(doctor_id)
      patient_hold = self.patient_hold_doctors.create(doctor_id: doctor_id, hold_at: Time.zone.now) if doctor
      if patient_hold
        doctor.update_columns(is_hold: true)
        puts "--------Schedule ReleaseDoctorWorker ---------"
        ReleaseDoctorWorker.perform_at(patient_hold.hold_at + 5.minutes, doctor_id, patient_hold.id, patient_hold.hold_at)
      end
    end
  end
  
  def return_doctor_to_available_list
    # Backup case if patient don't want to create appointment when have doctor 's HOLD status
    doctor_id = self.patient_doctors.select{|pd| pd.doctor.is_hold == true}.first.try(:doctor_id)
    if doctor_id.present?
      ReturnDoctorToAvailableListWorker.perform_at(self.changed_at + 5.minutes + 2.seconds, doctor_id, self.id)
    end
  end

  def set_inactive_old_cards(active_card_id: id, cc_type: cc_type)
    patient_credit_payments.where(cc_type: PatientCreditPayment.cc_types[cc_type]).where.not(id: active_card_id).update_all(is_active: false)
  end
  
  def as_json(options = {})
    {
      uid: id,
      fullname: fullname,
      email: email,
      phone_number: phone_number,
      fb_id: fb_id,
      fb_token: fb_token,
      auth_token: auth_token
    }
  end

  def as_json_total_credits(options = {})

    total = self.credits.where(is_used: false).where("expired_date >= ? ", Time.now.to_date).sum(:credit_number)

    {
      uid: id,
      fullname: fullname,
      email: email,
      total_credits: total.to_f
    }
  end

  def payments
    payment_array = []
    patient_credit_payments.active.each do |card|
      payment_array << ["#{card.masking_credit_number} - #{card.cc_type.upcase}", "#{card.class.name}:#{card.id}"]
    end
    paypal = PatientPaypalPayment.where(patient_id: id).order(updated_at: :desc).first
    payment_array << ["#{paypal.paypal_email} - PAYPAL", "#{paypal.class.name}:#{paypal.id}"]
    payment_array
  end

  def create_referral_code
    ReferralCode.find_or_create_by( sponsor_id: self.id )
  end

  def create_referral_info(referral_code=nil)
    if referral_code.nil?
      referral = ReferralCode.where(sponsor_id: self.referred_by).first
    else
      referral = ReferralCode.find_by_voucher_code(referral_code)
    end
    return if referral.nil?

    sponsor_id = referral.sponsor_id
    return if sponsor_id == self.id

    referral_info = ReferralInfo.where(referred_user_id: self.id).first
    refer_amount = GpdqSetting.find_by_name("Refer bonus").value.to_f
    ReferralInfo.find_or_create_by( referral_id: referral.id, referred_user_id: self.id ) do |referral_info|
      referral_info.refer_amount = refer_amount
    end
  end

  def has_running_appointment?
    if self.appointments.count == 0
      return false
    else
      appointments = self.appointments
      appointments.each do |apt|
        if !apt.canceled? && apt.status != 'complete'
          return true
          break
        end
      end
      false
    end
  end

  def execute_paypal_payment(amount)
    ret = {}
    begin      
      #token = self.paypal_access_token
      ppp = self.patient_paypal_payments.last 
      refresh_token = ppp && ppp.refresh_token ? ppp.refresh_token : ''
      if !refresh_token.blank?
        paypal_payment = PaypalPayment.new(refresh_token, amount)
        ret = paypal_payment.execute
      else
        ret = {success: false, errors: "Paypal refresh_token is not found." }
      end
      
    rescue Exception => ex
      logger.error("execute_paypal_payment error: #{ex.inspect}")
      ret = {success: false, errors: ex }
    end
    ret
  end

  def capture_paypal_payment(amount)
    ret = {}
    begin      
      #token = self.paypal_access_token
      ppp = self.patient_paypal_payments.last 
      refresh_token = ppp && ppp.refresh_token ? ppp.refresh_token : ''
      if !refresh_token.blank?
        paypal_payment = PaypalPayment.new(refresh_token, amount)
        ret = paypal_payment.capture_payment
      else
        ret = {success: false, errors: "Paypal refresh_token is not found." }
      end
      
    rescue Exception => ex
      logger.error("execute_paypal_payment error: #{ex.inspect}")
      ret = {success: false, errors: ex }
    end
    ret
  end

  def update_eta_and_hold_doctor
    if self.new_record? || self.zone_id_changed? || self.address_changed?
      self.save_eta_with_doctor
    end

    if self.new_record? && self.address.present?
      self.reload
      self.keep_hold_doctor_status
    end
  end


  protected

  def generate_auth_token
    self.auth_token = SecureRandom.urlsafe_base64
    generate_auth_token if self.class.exists?(auth_token: self.auth_token)
  end
end
