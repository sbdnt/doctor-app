class Api::V1::Doctors::AppointmentsController < Api::V1::Doctors::BaseController
  before_filter :api_authenticate_doctor!

  api :PUT, '/doctors/appointments/:id/confirm_on_way', "Doctor confirm on way an appointment"
  param_group :base_group, Api::V1::Docs::Doctors::SessionsDoc
  param :id, String, desc: "Appointment id", required: true
  example Api::V1::Docs::Doctors::AppointmentsDoc.confirm_on_way
  def confirm_on_way
    required :id

    apt = current_doctor.appointments.where(id: params[:id]).first
    if apt.present?
      if current_doctor.has_running_appointment?
        render status: 422, json: {success: false, errors: "You have a appointment not complete, so you can't comfirm on way for this appointment.", appointment: apt.reload.detail_as_json}
      else
        if apt.confirmed? && apt.normal? && !apt.bk_canceled?
          # if apt.paymentable_type == 'PatientCreditPayment'
          #   if apt.pre_auth_payment_with_default_fee
          #     apt.update_attributes(status: Appointment.statuses[:on_way])
          #     appointment_event = apt.create_appointment_event(event_static_name: "Doctor confirmed on way")
          #     appointment_event.push_notification
          #     render status: 200, json: {success: true, appointment: apt.reload.detail_as_json}
          #   else
          #     render status: 422, json: {success: false, errors: "Appointment can't be confirmed on way. Reason: payment pre-auth fail.", appointment: apt.reload.detail_as_json}
          #   end
          # else
          #   response = apt.patient.capture_paypal_payment(apt.appointment_fee.to_f)
          #   puts "response = #{response.inspect}"
          #   if response[:success]
          #     apt.update_attributes(status: Appointment.statuses[:on_way])
          #     appointment_event = apt.create_appointment_event(event_static_name: "Doctor confirmed on way")
          #     appointment_event.push_notification
          #     apt.paypal_transactions.create({appointment_id: apt.id, status: PaypalTransaction.statuses[response[:status]], payment_id: response[:payment_id], 
          #                                     payment_type: PaypalTransaction.payment_types[:capture], amount: response[:amount].to_f, currency: response[:currency], 
          #                                     authorization_id: response[:authorization_id], description: PaypalTransaction::ON_CONFIRM
          #                                   })
          #     render status: 200, json: {success: true, appointment: apt.reload.detail_as_json}
          #   else
          #     render status: 422, json: {success: false, errors: "Appointment can't be confirmed on way. Reason: capture payment with paypal fail.", appointment: apt.reload.detail_as_json}
          #     return
          #   end
          # end
          apt.update_attributes(status: Appointment.statuses[:on_way])
          appointment_event = apt.create_appointment_event(event_static_name: "Doctor confirmed on way")
          appointment_event.send_sms_and_notification()
          render status: 200, json: {success: true, appointment: apt.reload.detail_as_json}
        else
          if apt.on_way?
            render status: 200, json: {success: true, appointment: apt.reload.detail_as_json}
          else
            message = build_mess_errors_cancel_apt(apt)
            render status: 403, json: {success: false, errors: "Only confirmed appointment can be confirmed on way! #{message}", appointment: apt.reload.detail_as_json}
          end
        end
      end
    else
      render status: 422, json: {success: false, errors: "Appointment was not found or does not belong to you!"}
    end
  end

  api :PUT, '/doctors/appointments/:id/return_appointment', "Doctor cancel an appointment"
  param_group :base_group, Api::V1::Docs::Doctors::SessionsDoc
  param_group :cancel_appointment, Api::V1::Docs::Doctors::AppointmentsDoc
  example Api::V1::Docs::Doctors::AppointmentsDoc.return_appointment
  def return_appointment
    required :id

    apt = current_doctor.appointments.where(id: params[:id]).first
    if apt.present?
      if (apt.confirmed? || apt.on_way?) && apt.normal? && !apt.bk_canceled?

        ActiveRecord::Base.transaction do
          before_eta_minutes = ((apt.start_at - Time.zone.now) / 60).round
          reason_code_static_name = case 
          when before_eta_minutes >= 60
            "60 mins before ETA"
          when before_eta_minutes >= 30
            "30 mins before ETA"
          when before_eta_minutes >= 15
            "15 mins before ETA"
          end
          apt.update_attributes(doctor_id: nil, agency_id: nil, start_at: nil, end_at: nil, assigned_time_at: nil, status: Appointment.statuses[:pending], transport: 'transit')
          current_doctor.doctor_return_appointments.create(appointment_id: apt.id)
          apt.re_assign_after_return_apt
          current_doctor.update_doctor_appointments

          if reason_code_static_name
            appointment_event = apt.create_appointment_event(event_static_name: "Doctor Return", reason_code_static_name: reason_code_static_name, options: { standard: false })
            puts "appointment_event = #{appointment_event.inspect}"
            appointment_event.send_sms_and_notification()
          end
        end

        appointment = Appointment.where(doctor_id: current_doctor.id).active.order('assigned_time_at asc').first
        if appointment
          render status: 200, json: {success: true, appointment: appointment.reload.detail_as_json}
        else
          render status: 200, json: {success: true}
        end
      else
        message = build_mess_errors_cancel_apt(apt)
        render status: 403, json: {success: false, errors: "Only confirmed on way appointment can be returned! #{message}", appointment: apt.reload.detail_as_json}
      end
    else
      render status: 422, json: {success: false, errors: "Appointment was not found or does not belong to you!"}
    end
  end

  api :PUT, '/doctors/appointments/:id/delayed_appointment', "Doctor delayed 5 mins an appointment"
  param_group :base_group, Api::V1::Docs::Doctors::SessionsDoc
  param_group :delayed_appointment, Api::V1::Docs::Doctors::AppointmentsDoc
  example Api::V1::Docs::Doctors::AppointmentsDoc.delayed_appointment
  def delayed_appointment
    required :id
    required :delay_time

    delay_time = params[:delay_time]
    apt = current_doctor.appointments.where(id: params[:id]).first
    if apt.present?
      if apt.on_way? && apt.normal? && !apt.bk_canceled?
        if apt.start_at && apt.end_at
          apt.update_attributes({start_at: apt.start_at+delay_time.to_i*60, end_at: apt.end_at+delay_time.to_i*60, delayed_time: apt.delayed_time+delay_time.to_i})
          reason_code_static_name = case
            when delay_time >= 40
              "Late >40 minutes"
            when delay_time >= 20
              "Late >20 minutes"
            when delay_time >= 10
              "Late >10 minutes"
            end

          if reason_code_static_name          
            appointment_event = apt.create_appointment_event(event_static_name: "Doctor delayed", reason_code_static_name: reason_code_static_name, options: { standard: false })
            appointment_event.send_sms_and_notification()
          end
        end
        render status: 200, json: {success: true, appointment: apt.reload.detail_as_json}
      else
        message = build_mess_errors_cancel_apt(apt)
        render status: 403, json: {success: false, errors: "Only confirmed on way appointment can be delayed! #{message}", appointment: apt.reload.detail_as_json}
      end
    else
      render status: 422, json: {success: false, errors: "Appointment not found!"}
    end
  end

  api! "Get Appointment detail"
  param_group :base_group, Api::V1::Docs::Doctors::SessionsDoc
  param :id, String, desc: "Appointment id", required: true
  example Api::V1::Docs::Doctors::AppointmentsDoc.show
  def show
    appointment = Appointment.where(id: params[:id]).first
    if appointment
      render json: { success: true, appointment: appointment.detail_as_json }, status: 200
    else
      render json: { success: false, errors: 'This appointment does not exists.' }, status: 422
    end
  end

  api :PUT, '/doctors/appointments/:id/mark_appointment_started', "Doctor start an appointment"
  param :id, Integer, desc: "Appointment's id", :required => true
  param_group :base_group, Api::V1::Docs::Doctors::SessionsDoc
  example Api::V1::Docs::Doctors::AppointmentsDoc.mark_appointment_started
  def mark_appointment_started
    required :id

    apt = current_doctor.appointments.where(id: params[:id]).first
    if apt.present?
      if apt.on_way? && apt.normal? && !apt.bk_canceled?
        apt.update_attributes({start_at: Time.zone.now, end_at: Time.zone.now+Appointment::DEFAULT_APT_DURATION*60, 
                                status: Appointment.statuses[:on_process]
                              })
        appointment_address = apt.address
        doctor = apt.doctor
        doctor.update_attributes({address: appointment_address}) if appointment_address
        appointment_event = apt.create_appointment_event(event_static_name: "Dr Confirmed Appt started")
        appointment_event.send_sms_and_notification()

        puts apt.errors.inspect
        render status: 200, json: {success: true}
      else
        message = build_mess_errors_cancel_apt(apt)
        render status: 403, json: {success: false, errors: "Only confirmed on way appointment can be marked started! #{message}"}
      end
    else
      render status: 422, json: {success: false, errors: "Appointment was not found or does not belong to you!"}
    end
  end

  api :GET, '/doctors/appointments/:id/get_patient_phone', "Doctor get patient's phone(in appointment) to call"
  param :id, Integer, desc: "Appointment's id", :required => true
  param_group :base_group, Api::V1::Docs::Doctors::SessionsDoc
  example Api::V1::Docs::Doctors::AppointmentsDoc.get_patient_phone
  def get_patient_phone
    required :id

    apt = current_doctor.appointments.where(id: params[:id]).first
    if apt.present?
      render status: 200, json: {success: true, patient_name: apt.patient.try(:fullname), patient_phone: apt.patient.phone_number}
    else
      render status: 422, json: {success: false, errors: "Appointment was not found or does not belong to you!"}
    end
  end

  api! "Appointments counted by months, return only months have appointments. Counted appointments are cancelled appointments, completed appointments, (completed and paid) appointments"
  param_group :base_group, Api::V1::Docs::Doctors::SessionsDoc
  example Api::V1::Docs::Doctors::AppointmentsDoc.counted_by_months
  def counted_by_months
    appointments = Appointment.past_appointments_of_doctor(current_doctor.id)
    # Return only months have appointments
    appointments_by_months = appointments.group_by_month(:created_at, format: "%^B").count
    # Return all months and count appointments
    # appointments_by_months = appointments.group_by_month(:created_at, format: "%^B", range: Time.zone.now.at_beginning_of_year..Time.zone.now.at_end_of_year).count
    appointments_count = []
    appointments_by_months.each do |key, value|
      appointments_count << { month: key, count: value }
    end
    render json: { appointments_count: appointments_count }, status: 200
  end

  api! "Appointments counted in a specific month order by created at time"
  param_group :base_group, Api::V1::Docs::Doctors::SessionsDoc
  param :month_name, String, desc: "Full Month name", :required => true
  example Api::V1::Docs::Doctors::AppointmentsDoc.counted_in_month
  def counted_in_month
    appointment_returned_ids = DoctorReturnAppointment.where(doctor_id: current_doctor.id).pluck(:id)
    appointments = Appointment.includes(:patient, :invoice).except_invoiced_appointments_of_doctor(current_doctor.id, appointment_returned_ids).created_order
    appointments = appointments.by_calendar_month(params[:month_name])
    # time = Time.zone.parse(params[:month_name])
    # appointments = appointments.between(time.beginning_of_month, time.end_of_month).count
    # appointments = appointments.group_by_month(:created_at, range: time.beginning_of_month...time.end_of_month).count
    render json: { appointments: appointments.map { |a| a.past_data_of_doctor } }, status: 200
  end

  api! "Upcoming appointments order by start at time"
  param_group :base_group, Api::V1::Docs::Doctors::SessionsDoc
  example Api::V1::Docs::Doctors::AppointmentsDoc.upcoming
  def upcoming
    appointments = Appointment.includes(:patient).normal.where(doctor_id: current_doctor.id, status: [Appointment.statuses[:assigned], Appointment.statuses[:confirmed]]).order('assigned_time_at asc')
    current_appointment = Appointment.where(doctor_id: current_doctor.id).active.order('assigned_time_at asc').first
    appointments = appointments.where.not(id: current_appointment.id) if current_appointment
    render json: { appointments: appointments.map { |a| a.upcoming_data_of_doctor  } }, status: 200
  end

  api :POST, '/doctors/appointments/:id/create_invoice', "Doctor creat invoice for appointment"
  param :id, Integer, desc: "Appointment's id", :required => true
  param_group :invoice, Api::V1::Docs::Doctors::AppointmentsDoc
  example Api::V1::Docs::Doctors::AppointmentsDoc.create_invoice
  def create_invoice
    required :id

    apt = current_doctor.appointments.where(id: params[:id]).first
    if apt.present?
      if apt.ready_for_invoice?
        apt.update_attributes({ end_at: Time.zone.now, 
                                status: Appointment.statuses[:complete]
                              }) if apt.on_process?
        if apt.complete?
          invoice = Invoice.create(appointment_id: apt.id)
          unless invoice.errors.count > 0
            list_default = apt.appointment_fees
            list_default.each do |item|
              ItemsInvoice.create(price_item_id: item.price_item_id, invoice_id: invoice.id, item_price: item.price_per_unit, quantity: item.try(:quantity))
            end
            if params[:items].present?
              params[:items].each do |val|
                id = val[:id].to_i
                quantity = val[:quantity].to_i
                item = PriceItem.find_by_id(id)
                price = val[:price].nil? ? item.price_per_unit : val[:price].to_f
                ItemsInvoice.create(price_item_id: item.id, invoice_id: invoice.id, item_price: price, quantity: quantity) if item
              end
            end
            invoice.update_total_price
            appointment_event = apt.create_appointment_event(event_static_name: "Appointment complete")
            appointment_event.send_sms_and_notification()

            render status: 200, json: {success: true, invoice: invoice.as_json}
          else
            render status: 422, json: {success: false, errors: invoice.errors.full_messages.first}
          end
        else
          render status: 422, json: {success: false, errors: "This appointment can make as complete!"}
        end
      else
        render status: 403, json: {success: false, errors: "You can't create invoice for this appointment!"}
      end
    else
      render status: 422, json: {success: false, errors: "Appointment was not found or does not belong to you!"}
    end
  end

  # Author: Thanh
  # Update: Tan - change to get the current appoinment not the lastest updated appointment
  api! "Get current appointment except completed or cancelled appointment"
  param_group :base_group, Api::V1::Docs::Doctors::SessionsDoc
  example Api::V1::Docs::Doctors::AppointmentsDoc.current
  def current
    # appointment = Appointment.where(doctor_id: current_doctor.id).active.with_newest.first
    appointment = Appointment.where(doctor_id: current_doctor.id).active.order('assigned_time_at asc').first
    if appointment
      render json: { appointment: appointment.detail_as_json }, status: 200
    else
      render json: {}, status: 200
    end
  end

  api! "Get next appointments except current, completed or cancelled appointment"
  param_group :base_group, Api::V1::Docs::Doctors::SessionsDoc
  example Api::V1::Docs::Doctors::AppointmentsDoc.next_appointments
  def next_appointments
    appointments = Appointment.where(doctor_id: current_doctor.id).active.order('assigned_time_at asc')
    current_appointment = appointments.first
    next_appointments = appointments.where.not(id: current_appointment.id).map(&:detail_as_json)

    if next_appointments.any?
      render status: 200, json: { success: true, next_appointments: next_appointments }
    else
      render status: 400, json: { success: false, errors: "You don't have next appointments" }
    end
  end

  api :PUT, '/doctors/appointments/:id/confirm_appointment', "Doctor confirm to accept an appointment"
  param_group :base_group, Api::V1::Docs::Doctors::SessionsDoc
  param :id, String, desc: "Appointment id", required: true
  example Api::V1::Docs::Doctors::AppointmentsDoc.confirm_appointment
  def confirm_appointment
    required :id

    appointment = current_doctor.appointments.where(id: params[:id]).first
    if appointment.present?
      if appointment.assigned? && appointment.normal? && !appointment.bk_canceled?
        appointment.update_attributes(status: Appointment.statuses[:confirmed])
        render status: 200, json: {success: true, appointment: appointment.reload.detail_as_json}
      else
        if appointment.confirmed?
          render status: 200, json: {success: true, appointment: appointment.reload.detail_as_json}
        else
          message = build_mess_errors_cancel_apt(appointment)
          render status: 403, json: {success: false, errors: "Only assigned appointment can be confirmed! #{message}", appointment: appointment.reload.detail_as_json}
        end
      end
    else
      render status: 422, json: {success: false, errors: "Appointment was not found or does not belong to you!"}
    end
  end

  private

  def build_mess_errors_cancel_apt(appointment)
    if appointment.canceled?
      message = "This appointment's status is canceled."
    else
      case appointment.status
      when 'pending'
        message = "This appointment's status is pending."
      when 'on_way'
        message = "This appointment's status is on the way."
      when 'on_process'
        message = "This appointment's status is on processing."
      when 'assigned'
        message = "This appointment's status is on assigned."
      when 'confirmed'
        message = "This appointment's status is confirmed."
      else
        message = "This appointment's status is completed."
      end 
    end
    message
  end

end
