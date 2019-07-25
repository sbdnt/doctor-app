class Api::V1::Patients::AppointmentsController < Api::V1::BaseApiController
  skip_before_filter :api_authenticate_patient!, only: [:summary, :price_list]

  # Updated: Thanh
  api :GET, '/patients/appointments', "Get patient's appointment list. Upcoming appointments are not completed appointments (order by cancelled and newest appointments). Past appointments are completed appointments (order by newest appointments)."
  param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  param_group :get_apt, Api::V1::Docs::Patients::AppointmentsDoc
  example Api::V1::Docs::Patients::AppointmentsDoc.index
  def index
    required :auth_token
    required :scope

    if params[:scope] == 'live'
      live_appointments = current_patient.appointments
                          .includes(:invoice).active.created_order
      render json: { appointments: live_appointments.map{ |apt| apt.upcoming_data }}, status: 200
    elsif params[:scope] == 'past'
      past_appointments = current_patient.appointments
                          .includes(:invoice).where("status = ? OR is_canceled = ?", Appointment.statuses[:complete], Appointment.is_canceleds[:canceled])
                          .created_order
      render json: { appointments: past_appointments.map{ |apt| apt.past_data }}, status: 200
    else
      render status: 422, json: {success: false, errors: "Param scope can't be blank"}
    end
 
  end

  api :PUT, '/patients/appointments/:id/cancel_appointment', "Patient cancel an appointment"
  param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  param_group :cancel_appointment, Api::V1::Docs::Patients::AppointmentsDoc
  example Api::V1::Docs::Patients::AppointmentsDoc.cancel_appointment
  def cancel_appointment
    required :auth_token
    required :id
    patient = Patient.find_by_auth_token(params[:auth_token])
    if patient.present?
      apt = patient.appointments.where(id: params[:id]).first
      if apt.present?
        if !apt.complete? && apt.normal? && !apt.bk_canceled?
          doctor = apt.doctor
          apt.update_attributes(is_canceled: Appointment.is_canceleds[:canceled], booking_type: Appointment.booking_types[:bk_canceled], canceled_by_id: patient.id, canceled_by_type: patient.class.to_s)
          doctor.update_doctor_appointments if doctor.present?

          #Create invoice
          create_invoice_for_canceled_appointment(apt, current_patient)

          # Event: Patient Cancellation
          event = Event.where(static_name: "Patient Cancellation").first
          reason_code = ReasonCode.where(static_name: "Patient Cancelled via app").first
          patient_fee = apt.get_patient_fee
          options = { standard: false, patient_fee: patient_fee }
          appointment_event = apt.create_appointment_event(event_static_name: event.static_name, reason_code_static_name: reason_code.static_name, options: options)
          appointment_event.send_sms_and_notification()

          if apt.voucher_id
            voucher = Voucher.find_by_id(apt.voucher_id)
            if voucher.type != 'ReferralCode'
              apt.update_attributes( voucher_id: nil )
            end
            # voucher = Voucher.where(id: apt.voucher_id).first
            # voucher.update(is_used: false)
          end
          render status: 200, json: {success: true}
        else
          message = build_mess_errors_cancel_apt(apt)
          render status: 403, json: {success: false, errors: "Appointment can't be canceled! #{message}"}
        end
      else
        render status: 422, json: {success: false, errors: "Appointment not found or it does not belong to you!"}
      end
    else
      render status: 401, json: {success: false, errors: "Unauthorized"}
    end
  end

  api :GET, '/patients/appointments/summary', "Get appointment summary"
  #param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  param_group :doctor_around_param, Api::V1::Docs::Patients::MapsDoc
  example Api::V1::Docs::Patients::AppointmentsDoc.summary_desc
  def summary
    new_address = URI.unescape(params[:address]) if params[:address]
    if current_patient

      if (new_address.present? && current_patient.address != new_address) || (new_address.nil? && params[:lat].present? && params[:lng].present? && (current_patient.latitude != params[:lat].to_f || current_patient.longitude != params[:lng].to_f))
        GeoPatient.find(current_patient.id).save_location(params[:lat].to_f, params[:lng].to_f, new_address)
        current_patient.reload
      end
      min_eta_data = current_patient.get_min_eta
      min_eta = min_eta_data.try(:second)

      if min_eta_data.present? && min_eta.present?
        if min_eta.to_i < 10
          arrival_time = (min_eta_data.third - min_eta.minutes) + 10.minutes
        else
          arrival_time = min_eta_data.third
        end
        arrival_time = arrival_time.try(:strftime, "%H:%M").to_s
      else
        arrival_time = Time.zone.now.strftime("%H:%M")
      end

    else
      temp_patient = new_address.present? ? TempPatient.find_or_create_by(address: new_address) : TempPatient.new
      temp_patient.save_location(params[:lat].to_f, params[:lng].to_f, new_address) if params[:lat].present? && params[:lng].present?
      min_eta = temp_patient.get_min_eta
      min_eta = 10 if min_eta.present? && min_eta < 10
      arrival_time = (Time.zone.now + min_eta.to_i.minutes).try(:strftime, "%H:%M")
    end
    # default_price_items = PriceItem.where(is_default: true).sum(:price_per_unit).to_f
    appointment_fee = Appointment.cal_appointment_fee(Time.zone.now)
    render json: {arrival_time: arrival_time, appointment_fee: appointment_fee}
  end

  api :GET, '/patients/appointments/booking_confirmed', "Get booking confirmed"
  param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  example Api::V1::Docs::Patients::AppointmentsDoc.booking_confirmed_desc
  def booking_confirmed
    min_eta_data = current_patient.get_min_eta
    min_eta = min_eta_data.try(:second)

    if min_eta_data.present? && min_eta.present?
      if min_eta.to_i < 10
        arrival_time = (min_eta_data.third - min_eta.minutes) + 10.minutes
      else
        arrival_time = min_eta_data.third
      end
      arrival_time = arrival_time.try(:strftime, "%H:%M").to_s
    else
      arrival_time = Time.zone.now.strftime("%H:%M")
    end

    profile_doctor = {}
    if min_eta_data.first.present?
      doctor = Doctor.find_by_id(min_eta_data.first)
      host = request.protocol + request.host_with_port
      profile_doctor = doctor.as_json_view_profile({host: host}).except(:about)
    end
    render json: {arrival_time: arrival_time, doctor_profile: profile_doctor}
  end

  api :PUT, '/patients/appointments/:id/rating', "Rate doctor on an appointment"
  param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  param_group :rating_params, Api::V1::Docs::Patients::AppointmentsDoc
  example Api::V1::Docs::Patients::AppointmentsDoc.rating_desc
  def rating
    appoint = Appointment.find_by_id(params[:id])
    if appoint
      appoint.rating = params[:rating_of_quality].to_i if params[:rating_of_quality].present?
      appoint.rating_manner = params[:rating_of_manner].to_i if params[:rating_of_manner].present?
      appoint.comment = params[:comment]
      puts "appointment rating before= #{appoint.inspect}"
      if appoint.save
        render json: {success: true}
      else
        render json: {success: false, errors: appoint.errors.full_messages.first}, status: 400
      end
      puts "appointment rating after= #{appoint.inspect}"
    else
      render json: {success: false, errors: "Appointment's id does not exist."}
    end
  end

  api :GET, '/patients/appointments/:id/rating_detail', "Get rating detail of an appointment"
  param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  example Api::V1::Docs::Patients::AppointmentsDoc.rating_detail
  def rating_detail
    appoint = Appointment.find_by_id(params[:id])
    if appoint
      if appoint.status == Appointment::COMPLETE
        rating = appoint.rating.present? && appoint.rating_manner != 0 ? {quality: appoint.rating, manner: appoint.rating_manner, comment: appoint.comment.to_s} : {}
        render status: 200, json: appoint.rating_detail_json.merge(rating)
      else
        render status: 200, json: {}
      end
    else
      render json: {success: false, errors: "Appointment not found or it does not belong to you!"}
    end
  end

  api :POST, '/patients/appointments', "Create new appointment"
  param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  param_group :appointment, Api::V1::Docs::Patients::AppointmentsDoc
  example Api::V1::Docs::Patients::AppointmentsDoc.create
  def create
    if current_patient.has_running_appointment?
      render json: { success: false, errors: "Your current appointment is not complete!" }, status: :unprocessable_entity
    else
      appointment = Appointment.new(appointment_params)
      appointment.status = 'pending'
      appointment.patient_id = current_patient.id
      appointment.voucher_id = nil
      appointment.appointment_fee = Appointment.cal_appointment_fee(Time.zone.now)

      # Check available booking time - updated by Tan
      # invalid_booking_time = appointment.check_available_booking_time
      # if invalid_booking_time
      #   render json: { success: false, error: "Sorry, there are no available doctors to create this appointment. Our doctors' working time is from 8:00 AM to 11:00 PM" }, status: :unprocessable_entity
      #   return
      # end

      # Check voucher code
      if params[:voucher_code].present?
        voucher = Voucher.where(voucher_code: params[:voucher_code]).first
        if voucher
          if !voucher.check_valid_code(current_patient.id)
            render json: { success: false, errors: "This voucher code already used!" }, status: :unprocessable_entity
            return
          else
            if voucher.type == 'ReferralCode'
              if current_patient.got_first_booking?
                render json: { success: false, errors: "You can only use this referral code for first booking!" }, status: :unprocessable_entity
                return
              end

              sponsor_id = voucher.sponsor_id
              if sponsor_id == current_patient.id
                render json: { success: false, errors: "You can not used your own referral code!" }, status: :unprocessable_entity
                return
              else
                current_patient.create_referral_info(params[:voucher_code])
              end
            end

            appointment.voucher_id = voucher.id
          end
        else
          render json: { success: false, errors: "This voucher code not found!" }, status: :unprocessable_entity
          return
        end
      end

      if appointment_params[:paymentable_type] == "PatientCreditPayment"
        if appointment.pre_auth_validate_method
          save_appointment(appointment: appointment, current_patient: current_patient, payment_method: 'credit_card')
        else
          render json: { success: false, errors: "PreAuth with credit card fail!" }, status: :unprocessable_entity
          return
        end
      else
        puts "current_patient = #{current_patient.inspect}"
        response = current_patient.capture_paypal_payment(appointment.appointment_fee)
        puts "response = #{response.inspect}"
        if response[:success]
          save_appointment(appointment: appointment, current_patient: current_patient, payment_method: 'paypal', response: response)
        else
          render json: { success: false, errors: "PreAuth with paypal fail!" }, status: :unprocessable_entity
          return
        end
      end
    end
  end

  api :GET, "/patients/appointments/doctor_info", "Get doctor information of last patient's appointment. Returned appointment is not cancelled or completed."
  param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  example Api::V1::Docs::Patients::AppointmentsDoc.doctor_info
  def doctor_info
    appointment = Appointment.where(patient_id: current_patient.id).active.order('assigned_time_at asc').first
    doctor = appointment.try(:doctor)
    if appointment && doctor
      render json: { doctor: doctor.info_as_json, appointment: appointment.detail_as_json }, status: 200 and return
    end
    if appointment
      render json: { appointment: appointment.detail_as_json }, status: 200 and return
    else
      render json: {}, status: 200 and return
    end
  end

  api :GET, '/patients/appointments/:id/final_invoice', "Get patient's final invoice of an appointment"
  param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  param :id, Integer, desc: "Appointment's id", :required => true
  example Api::V1::Docs::Patients::AppointmentsDoc.final_invoice
  def final_invoice
    required :auth_token
    required :id
    apt = current_patient.appointments.where(id: params[:id]).first
    if apt.present?
      if apt.invoice.present?
        invoice_id = apt.invoice.id
        price_item_ids = ItemsInvoice.where(invoice_id: apt.invoice.id).pluck(:price_item_id).uniq
        category_ids = PriceItem.with_deleted.find(price_item_ids).map(&:category_id).uniq
        @categories = PriceCategory.where(id: category_ids)
        addition_apt_fee = PriceCategory.find_by(cat_type: "appointment_fee").as_json_for_apt_fee
        addition_apt_fee[:items].first[:price_per_unit] = apt.appointment_fee.to_f
        if apt.invoice.discount > 0
          voucher_cat = PriceCategory.find_by(cat_type: "voucher").as_json_for_single_item
          voucher_cat[:items].first[:price_per_unit] = apt.invoice.discount.to_f
        else
          voucher_cat = []
        end
        if apt.get_extra_fee > 0
          # Check invoice include? any item in category Extras
          extras_category = PriceCategory.find_by(cat_type: "extension")
          extras_cat_name = extras_category.try(:name)
          extras_price_name = PriceItem.find_by(price_type: "extension").try(:name)
          if category_ids.include?(PriceCategory.find_by(cat_type: "extension").try(:id))
            extras_category_json = extras_category.as_json_for_invoice(price_item_ids, invoice_id)
            extras = {name: extras_price_name, price_per_unit: apt.get_extra_fee.to_f, quantity: 1, extend_time: "#{apt.extend_time} mins"}
            extras_category_json[:items]<<extras
            categories_array = [addition_apt_fee]<<@categories.except_apt_fee_cat.except_apt_extension_cat.except_voucher_cat.map {|c| c.as_json_for_invoice(price_item_ids, invoice_id)}<<extras_category_json<<[voucher_cat]
          else
            addition_apt_extra = {name: extras_cat_name, allow_expand: true, allow_patient_expand: extras_category.allow_patient_expand, items: [{name: extras_price_name, price_per_unit: apt.get_extra_fee.to_f, quantity: 1, extend_time: "#{apt.extend_time} mins"}]}
            categories_array = [addition_apt_fee]<<@categories.except_apt_fee_cat.except_voucher_cat.map {|c| c.as_json_for_invoice(price_item_ids, invoice_id)}<<addition_apt_extra<<[voucher_cat]
          end
          puts "categories_array = #{categories_array.flatten.inspect}"
          render status: 200, json: {invoice: apt.invoice.as_json, categories: categories_array.flatten, appointment_rated: (apt.rating.try(:>, 0) || apt.rating_manner.try(:>, 0)), doctor_name: apt.doctor.last_name}
        else
          categories_array = [addition_apt_fee]<<@categories.except_apt_fee_cat.except_voucher_cat.map {|c| c.as_json_for_invoice(price_item_ids, invoice_id)}<<[voucher_cat]
          render status: 200, json: {invoice: apt.invoice.as_json, categories: categories_array.flatten, appointment_rated: (apt.rating.try(:>, 0) || apt.rating_manner.try(:>, 0)), doctor_name: apt.doctor.last_name}
        end
      else
        render status: 200, json: {}
      end
    else
      render status: 422, json: {errors: "Appointment not found or does not belong to you!"}
    end
  end

  api :GET, '/patients/appointments/price_list', "Get GPDQ's price list"
  example Api::V1::Docs::Patients::AppointmentsDoc.price_list
  def price_list
    desc = PriceList.find_by(price_type: "price_desc").try(:is_published) ? PriceList.find_by(price_type: "price_desc").try(:description) : nil
    # drug_delivery = PriceList.find_by(price_type: "drug_delivery")
    if desc.present?
      render status: 200, json: {price_list: PriceList.order(order: :asc).select{|p| p.price_type != 'price_desc'}.map{|p| p.as_json}}.merge!({desc: desc})
    else
      render status: 200, json: {price_list: PriceList.order(order: :asc).select{|p| p.price_type != 'price_desc'}.map{|p| p.as_json}}
    end
  end

  api :GET, '/patients/appointments/pending_invoice', "Get pending invoice(payment failured) of patient"
  param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  example Api::V1::Docs::Patients::AppointmentsDoc.pending_invoice
  def pending_invoice
    required :auth_token

    appointment_ids = current_patient.appointments.select{|apt| apt.complete?}.map(&:id)
    if appointment_ids.count > 0
      invoices = Invoice.pending.where(appointment_id: appointment_ids)
      if invoices.count > 0
        render status: 200, json: {invoices: invoices.map{|inv| inv.as_json}}
      else
        render status: 200, json: {}
      end
    else
      render status: 200, json: {}
    end
  end

  private
  def appointment_params
    params.require(:appointment).permit(:paymentable_id, :paymentable_type, :lat, :lng, :address, :lat_bill_address, :lng_bill_address, :bill_address)
  end

  def save_appointment(options)
    appointment = options[:appointment]
    if appointment.save
      # voucher.update(is_used: true) if appointment.voucher_id
      voucher = appointment.voucher
      if voucher.present?
        if voucher.type == 'ReferralCode'
          voucher.create_credit_for_sponsor(appointment.id)
        end
      end
      if options[:payment_method] == 'credit_card'
        tran = JudoTransaction.where(appointment_id: nil, your_consumer_reference: "consumer_#{options[:current_patient].phone_number}").last
        tran.update_attributes(appointment_id: appointment.id) if tran
      else
        response = options[:response]
        appointment.paypal_transactions.create({appointment_id: appointment.id, status: PaypalTransaction.statuses[response[:status]], payment_id: response[:payment_id], 
                                                payment_type: PaypalTransaction.payment_types[:capture], amount: response[:amount].to_f, currency: response[:currency], 
                                                authorization_id: response[:authorization_id], description: PaypalTransaction::ON_BOOKED
                                              })
      end
      # Find patient to reload patient's data
      patient = Patient.find_by_id(current_patient.id)
      holding_doctor_id = patient.patient_hold_doctors.joins(:doctor).where('patient_hold_doctors.release_at IS NULL AND doctors.is_hold = ?', true).first.try(:doctor_id)
      CheckAssignedDoctorConfirmWorker.new.perform(appointment.id, current_patient.id, holding_doctor_id)
      # Track default price items at the current time when create an appointment
      appointment.track_appointment_fees

      # Event: Patient confirms booking request
      appointment_event = appointment.create_appointment_event(event_static_name: "Booking confirmed", options: { standard: true })
      appointment_event.send_sms_and_notification()

      render json: { success: true }, status: :created
    else
      render json: { success: false, errors: appointment.errors.full_messages.first }, status: :unprocessable_entity
    end
  end

  def create_invoice_for_canceled_appointment(appointment, patient)
    # Create Invoice if appointment status is [onway, on_process]
    if appointment.on_way? || appointment.on_process?
      invoice = Invoice.create(total_prices: appointment.appointment_fee, appointment_id: appointment.id)
      if appointment.paymentable_type == "PatientPaypalPayment"
        # Collection captured payment(appointment fee) for paypal
        captured_payment = PaypalTransaction.find_by(appointment_id: appointment.id, payment_type: PaypalTransaction.payment_types[:capture], amount: appointment.appointment_fee)
        if captured_payment
          refresh_token = PatientPaypalPayment.find_by(id: appointment.paymentable_id).refresh_token
          access_token = PaypalPayment.get_access_token(refresh_token)
          collecttion_response = PaypalPayment.final_capture_payment(captured_payment.authorization_id, access_token, appointment.appointment_fee, is_final=false)
          puts "====================="
          puts "collecttion_response = #{collecttion_response.inspect}"
          puts "====================="
          if collecttion_response[:success]
            appointment.paypal_transactions.create({ status: PaypalTransaction.statuses["#{collecttion_response[:status]}"], amount: collecttion_response[:amount], currency: collecttion_response[:currency], 
                                                      description: PaypalTransaction::ON_CANCELED, payment_id: collecttion_response[:payment_id], payment_type: PaypalTransaction.payment_types[:collection]
                                                    })
            invoice.update_columns(status: Invoice.statuses["closed"])
          end
        end
      else
        # Get receipt_id of PreAuth apppointment fee
        receipt_id = JudoTransaction.find_by(appointment_id: appointment.id, payment_type: JudoTransaction.payment_types["PreAuth"], amount: appointment.appointment_fee).try(:receipt_id)
        # Collect appointment fee preauth
        if receipt_id
          conn = Faraday.new(:url => "https://#{JUDOPAY[:token]}:#{JUDOPAY[:secret]}@#{JUDOPAY[:host]}/transactions") do |faraday|
            faraday.request  :url_encoded
            faraday.response :logger
            faraday.adapter  Faraday.default_adapter
          end
          params_collect = {receiptId: receipt_id, amount: appointment.appointment_fee, yourPaymentReference: "payment_#{patient.phone_number}"}
          response_collect = conn.post do |req|
            req.url "collections"
            req.headers['Content-Type'] = 'application/json'
            req.headers['API-Version'] = '4.1'
            req.body = params_collect.to_json
          end
          response_collect = JSON.parse(response_collect.body)
          JudoTransaction.create_tran(response_collect.symbolize_keys, appointment.id)
          success_collect = (response_collect['result'] == 'Success')
          invoice.update_columns(status: Invoice.statuses["closed"]) if success_collect
          puts "response_collect = #{response_collect.inspect}"
        end
      end
    end
  end

  def build_mess_errors_cancel_apt(appointment)
    if appointment.canceled?
      message = "Your appointment has already canceled."
    else
      case appointment.status
      when 'on_way'
        message = "Your doctor is on the way."
      when 'on_process'
        message = "Your appointment is on processing."
      else
        message = "Your appointment was completed."
      end 
    end
    message
  end
end
