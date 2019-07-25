class AppointmentEvent < ActiveRecord::Base

  # ASSOCIATIONS
  belongs_to :appointment
  belongs_to :event
  belongs_to :reason_code
  belongs_to :patient
  belongs_to :doctor

  # SCOPES

  # VALIDATIONS
  validates :appointment_id, :event_id, presence: true
  validates :created_manual, :standard,
    inclusion: { in: [true, false], message: "%{value} is not a valid value (true or false)" },
    allow_blank: true

  # Instance methods should follow Alphabet rules
  def get_message(patient_name: nil, doctor_name: nil)
    doctor_sms = nil
    doctor_push = nil
    patient_sms = nil
    patient_push = nil
    reason_code_static_name = reason_code.try(:static_name)
    case event.static_name
    when "Cancelation - GPDQ Error"
      case reason_code_static_name
      when "GPDQ Platform Error"
        doctor_sms = "Dear Dr #{doctor_name}, We have cancelled your next appointment due to a technical error. Please email your GPDQ account manager for further information"
      when "Back office mistake", "Tech error", "Unspecified"
        doctor_sms = "Yes"
      end
    when "Patient Cancellation"
      case reason_code_static_name
      when "Patient Cancelled via app"
        doctor_sms = "Dear Dr #{doctor_name}, #{patient_name} has now cancelled booking ref #{appointment_id}. Cancellation credits may be applicable, please contact your account manager for further information"
        patient_sms = "Your cancellation was successful. A cancellation fee will be deducted from your account if the doctor has been despatched to your booking"
      when "Patient didn't answer door"
        patient_sms = "Dear #{patient_name}, your booking ref #{appointment_id} has been cancelled as the doctor was unable to locate you. As per our t&c's a cancellation fee is applicable"
      when "Due to delay"
        doctor_sms = "Dear Dr #{doctor_name}, we have now cancelled your next appt as the patient has informed us they are unable to wait any longer"
      when "Due to return"
        doctor_sms = "Dear Dr #{doctor_name}, your recent return resulted in cancellation by the patient. As per our terms and conditions a customer compensation credit is required."
      when "Prior to doctor confirming on route"
        doctor_sms = "Dear Dr #{doctor_name},  we wanted to inform you that the booking in your dashboard has now been cancelled by the patient. Please do not proceed to the appointment"
      when "Serious medical issue with Patient"
        doctor_sms = "Dear Dr #{doctor_name}, your upcoming booking has been cancelled by the patient due to a serious medical emergency."
      end
    when "Doctor Return"
      case reason_code_static_name
      when "60 mins before ETA", "30 mins before ETA"
        patient_sms = " dr #{doctor_name} has just informed us he/she will be unable to complete your appt due to an unexpected issue. GPDQ has found you a replacement doctor , track him/her here!"
      when "15 mins before ETA"
        patient_sms = " dr #{doctor_name} has just informed us he/she will be unable to complete your appt due to an unexpected issue. GPDQ has found you a replacement doctor who will arrive within 15 minutes , track him/her here!"
      end
    when "Doctor delayed"
      case reason_code_static_name
      when "Late >10 minutes"
        patient_sms = "Dr #{doctor_name} is running 10 minutes late, apologies for the inconvenience"
      when "Late >20 minutes"
        patient_sms = "Doctor #{doctor_name} is running late due to traffic and will be with you as soon as possible."
      when "Late >40 minutes"
        patient_sms = "Unfotunately Dr #{doctor_name} has been delayed due to an extention with his previous patient & will be with you shortly. A member of our team will contact you to resolve this"
      end
    when "Other Customer Service Event"
      patient_sms = "Reactive"
      patient_push = "Reactive"
    when "Booking confirmed"
      patient_sms = "Yes"
    when "Dispached to doctor"
      doctor_sms = "Dear Dr #{doctor_name}, your next appointment is waiting for acceptance."
      doctor_push = "You have a new appointment awaiting acceptance"
    when "Doctor not yet confirmed on way when due"
      doctor_sms = "Dear Dr #{doctor_name}, please accept your next booking or contact us if you are unable to fulfill this"
    when "Doctor confirmed on way"
      patient_sms = "Hi #{patient_name}, your booking ref #{appointment_id} is  confirmed and doctor #{doctor_name} is on his way. Track him here <link>/track on link"
    when "Reminder to Doctor that appt ends in 5 minutes"
      doctor_push = "Dr #{doctor_name}, your appointment is coming to an end in 5 minutes. If you need an extension, please inform the patient"
    when "Appointment extension in 5 min increments (increment + 3 mins is regarded as the lower increment)"
      case reason_code_static_name
      when "5 minute extension"
        patient_sms = "Hi #{patient_name}, Your appointment has been extended and any applicable charges will be available to view on your receipt"
      end
    when "Additional Onsite Consultation"
      case reason_code_static_name
      when "New Patient"
        patient_sms = "You have requested an additional consultation with Dr #{doctor_name} which will be deducted from your chosen payment method"
      end
    end
    message = { doctor_sms: doctor_sms, doctor_push: doctor_push, patient_sms: patient_sms, patient_push: patient_push }
  end

  def push_notification(receiver: "patient", custom_data: {})
    message = event.static_name
    app_message = message
    event_type = event.name_for_push
    event_message = if reason_code_id
      EventMessage.where(event_id: event_id, reason_code_id: reason_code_id).first
    else
      EventMessage.where(event_id: event_id).first 
    end

    platform = ""
    device_token = ""
    for_app = receiver

    if event_message
      case
      when receiver == "patient"
        message = event_message.patient_push
        app_message = event_message.patient_push_in_app

        patient = Patient.where(id: patient_id).first
        platform = patient.platform
        device_token = patient.device_token
      when receiver == "doctor"
        message = event_message.doctor_push
        app_message = event_message.doctor_push_in_app

        doctor = Doctor.where(id: doctor_id).first
        platform = doctor.platform
        device_token = doctor.device_token
      end
    end

    if platform.present? && device_token.present?
      custom = { 
        appointment_id: appointment_id,
        app_message: app_message
      }.merge(custom_data)

      pusher = PushNotification.new(platform: platform, for_app: for_app)
      case platform
      when "ios"
        pusher.push_event(device_token: device_token, message: message, custom: custom, event_type: event_type)
      when "android"
        pusher.push_event(device_token: [device_token], message: message, custom: custom, event_type: event_type)
      end
    end
  end

  def send_only_sms
    patient_name = patient.try(:fullname)
    doctor_name = doctor.try(:last_name)
    case event.static_name
    when "Doctor Return"
      event_message = EventMessage.where(event_id: event_id, reason_code_id: reason_code_id).first
      puts "event_message = #{event_message.inspect}"
      if event_message && event_message.patient_sms.present?
        patient_sms = event_message.patient_sms
        patient_phone = patient.try(:phone_number)
        doctor_name = doctor.try(:last_name)
        SmsSystem.send_and_track_sms({to: patient_phone, message: patient_sms.gsub("%{doctor_name}", doctor_name), originator: "GPDQ", patient_id: patient_id, sent_via: SmsSystem.sent_via[:app]})
      end
    when "Doctor delayed"
      event_message = EventMessage.where(event_id: event_id, reason_code_id: reason_code_id).first
      if event_message
        patient_sms = event_message.patient_sms
        patient_phone = patient.try(:phone_number)
        doctor_name = doctor.try(:last_name)
        SmsSystem.send_and_track_sms({to: patient_phone, message: patient_sms.gsub("%{doctor_name}", doctor_name), originator: "GPDQ", patient_id: patient_id, sent_via: SmsSystem.sent_via[:app]})
      end
    when "Booking confirmed"
      event_message = EventMessage.where(event_id: event_id).first
      if event_message
        patient_name = patient.try(:fullname)
        patient_phone = patient.phone_number
        patient_sms = event_message.patient_sms
        SmsSystem.send_and_track_sms({to: patient_phone, message: patient_sms.gsub("%{patient_name}", patient_name).gsub("%{appointment_id}", appointment_id.to_s), originator: "GPDQ", patient_id: patient_id, sent_via: SmsSystem.sent_via[:app]})
      end
    when "Doctor not yet confirmed on way when due"
      event_message = EventMessage.where(event_id: event_id).first
      if event_message
        # Send to doctor if appointment was assigned
        if doctor_id.present?
          doctor_name = doctor.try(:last_name)
          doctor_phone = doctor.try(:phone_number)
          doctor_sms = event_message.doctor_sms.gsub("%{doctor_name}", doctor_name)
          SmsSystem.send_and_track_sms({to: doctor_phone, message: doctor_sms, originator: "GPDQ", doctor_id: doctor_id, sent_via: SmsSystem.sent_via[:app]})
        end
      end
    end
  end

  def send_sms_and_notification
    patient_name = patient.try(:fullname)
    doctor_name = doctor.try(:last_name)
    # Send PUSH NOTIFICATION and SMS (optional, if events required) to patient and doctor
    case event.name_for_push
    when "dispached_doctor"
      if doctor_id.present? && appointment.assigned?
        push_notification(receiver: "doctor")
        
        # Send SMS to doctor
        event_message = EventMessage.where(event_id: event_id).first
        if event_message
          doctor_sms = event_message.doctor_sms
          doctor_phone = doctor.try(:phone_number)
          doctor_name = doctor.try(:last_name)
          SmsSystem.send_and_track_sms({to: doctor_phone, message: doctor_sms.gsub("%{doctor_name}", doctor_name), originator: "GPDQ", doctor_id: doctor_id, sent_via: SmsSystem.sent_via[:app]})
        end
      end
    when "doctor_on_way"
      push_notification()
    when "appointment_complete"
      push_notification()
    when "patient_cancellation"
      event_message = EventMessage.where(event_id: event_id, reason_code_id: reason_code_id).first
      if event_message
        patient_phone = patient.phone_number
        patient_sms = event_message.patient_sms
        SmsSystem.send_and_track_sms({to: patient_phone, message: patient_sms, originator: "GPDQ", patient_id: patient_id, sent_via: SmsSystem.sent_via[:app]})
        # Send to doctor if appointment was assigned
        if doctor_id.present?
          push_notification(receiver: "doctor")

          doctor_phone = doctor.try(:phone_number)
          doctor_sms = event_message.doctor_sms.gsub("%{doctor_name}", doctor_name).gsub("%{patient_name}", patient_name).gsub("%{appointment_id}", appointment_id.to_s)
          SmsSystem.send_and_track_sms({to: doctor_phone, message: doctor_sms, originator: "GPDQ", doctor_id: doctor_id, sent_via: SmsSystem.sent_via[:app]})
        end
      end
    when "dr_confirmed_appointment_started"
      push_notification()
    else
      # Send SMS for events which does not have PUSH NOTIFICATION
      send_only_sms()
    end
  end

  def track_patient_cs_credit
    expired_setting = GpdqSetting.where(name: "Expired CS Credit").first
    expired_date = created_at
    expired_value = expired_setting.value.to_i
    expired_date = case expired_setting.time_unit
    when "day"
      expired_date + expired_value.days
    when "month"
      expired_date + expired_value.months
    when "year"
      expired_date + expired_value.years
    end

    new_credit = {
      patient_id: patient_id,
      appointment_id: appointment_id,
      credit_number: patient_credit,
      expired_date: expired_date,
      is_used: false,
      credit_type: Credit.credit_types["CS"]
    }
    Credit.create(new_credit)
  end

end
