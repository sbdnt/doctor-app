# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Admin.destroy_all

Admin.create!(email: 'admin@doctorapp.com', password: '1234qwer', password_confirmation: '1234qwer') unless Admin.find_by_email("admin@doctorapp.com").present?
Admin.create!(email: 'admin2@doctorapp.com', password: '1234qwer', password_confirmation: '1234qwer') unless Admin.find_by_email("admin2@doctorapp.com").present?

# Zone.destroy_all

xlsx = Roo::Spreadsheet.open("#{Rails.root}/lib/assets/new_zone_ticket_164.xlsx")
puts "--Starting import new zone ---"
xlsx.each do |x|
  Zone.find_or_create_by(name: x[0])
end
puts "--Import new zone done ---"

xlsx = Roo::Spreadsheet.open("#{Rails.root}/lib/assets/subzone.xlsx")
puts "--Starting import new sub zone ---"
xlsx.each do |x|
  zone = Zone.find_by(name: x[0].scan(/\w+\d+/))
  zone.sub_zones.find_or_create_by(name: x[0]) if zone.present?
end
puts "--Import new sub zone done ---"

##### CREATE INITIAL EVENTS #####
p "Create Initial Event Categories"
appointment_category_id = EventCategory.find_or_create_by!(name: "Appointment").id
payment_category_id = EventCategory.find_or_create_by!(name: "Payment").id
doctor_shift_category_id = EventCategory.find_or_create_by!(name: "Doctor Shift").id

p "Create Initial Events"
Event.find_or_create_by!(name: "Cancelation - GPDQ Error", event_category_id: appointment_category_id, 
    standard: false, doctor_sms: true)
["GPDQ Platform Error", "Back office mistake", "Tech error", "Unspecified"].each do |code_name|
  ReasonCode.find_or_create_by!(name: code_name)
end

event_name = "Patient Cancellation"
Event.find_or_create_by!(name: "Patient Cancellation", event_category_id: appointment_category_id,
  standard: false, created_via_app: true, doctor_sms: true, patient_sms: true)
["Patient Cancelled via app", "Patient didn't answer door", "Due to delay", "Due to return",
  "Prior to doctor confirming on route", "Serious medical issue with Patient"
].each do |code_name|
  ReasonCode.find_or_create_by!(name: code_name)
end

Event.find_or_create_by!(name: "Doctor Return", event_category_id: appointment_category_id, 
    standard: false, created_via_app: true, patient_sms: true)
["60 mins before ETA", "30 mins before ETA", "15 mins before ETA"].each do |code_name|
  ReasonCode.find_or_create_by!(name: code_name)
end

Event.find_or_create_by!(name: "Doctor delayed", event_category_id: appointment_category_id, 
    standard: false, created_via_app: true, patient_sms: true)
["Late >10 minutes", "Late >20 minutes", "Late >40 minutes"].each do |code_name|
  ReasonCode.find_or_create_by!(name: code_name)
end

Event.find_or_create_by!(name: "Other Customer Service Event", event_category_id: appointment_category_id, 
    standard: false, created_via_back_end: true)
[
  "ETA outside of marketing promise",
  "Inappropriate behaviour", "Inappropriate behaviour - serious", 
  "Contact with patient after appointment unless instigated by patient",
  "Offering direct services", "Inaccurately charging extra time", "Other"
].each do |code_name|
  ReasonCode.find_or_create_by!(name: code_name)
end

Event.find_or_create_by!(name: "Booking confirmed", event_category_id: appointment_category_id, 
    standard: true, created_via_back_end: true, patient_sms: true)
Event.find_or_create_by!(name: "Dispached to doctor", event_category_id: appointment_category_id, 
    standard: true, created_via_back_end: true, doctor_sms: true, doctor_push: true)
Event.find_or_create_by!(name: "Doctor not yet confirmed on way when due", event_category_id: appointment_category_id, 
    standard: false, created_via_back_end: true, doctor_sms: true)
Event.find_or_create_by!(name: "Doctor confirmed on way", event_category_id: appointment_category_id, 
    standard: true, created_via_app: true, patient_push: true)
Event.find_or_create_by!(name: "Doctor 500m away", event_category_id: appointment_category_id, 
    standard: true, created_via_back_end: true, doctor_push: false)
Event.find_or_create_by!(name: "Doctor confirmed arriving", event_category_id: appointment_category_id, 
    standard: true, created_via_back_end: true)
Event.find_or_create_by!(name: "Dr Confirmed Appt started", event_category_id: appointment_category_id, 
    standard: true, created_via_app: true)
Event.find_or_create_by!(name: "Reminder to Doctor that appt ends in 5 minutes", event_category_id: appointment_category_id, 
    standard: true, created_via_back_end: true, doctor_push: true)

event_name = "Appointment extension in 5 min increments (increment + 3 mins is regarded as the lower increment)"
Event.find_or_create_by!(name: event_name, event_category_id: appointment_category_id, 
    standard: false, created_via_back_end: true, patient_sms: true)
[5, 10, 15, 20].each do |minute|
  ReasonCode.find_or_create_by!(name: "#{minute} minute extension")
end

Event.find_or_create_by!(name: "Additional Onsite Consultation", event_category_id: appointment_category_id, 
    standard: false, created_via_back_end: true, patient_sms: true)
reason_code = ReasonCode.find_or_create_by!(name: "New Patient")

Event.find_or_create_by!(name: "Appointment complete", event_category_id: appointment_category_id, 
    standard: true, created_via_back_end: true,
    patient_sms: true)
Event.find_or_create_by!(name: "Full-value payment pre-auth", event_category_id: payment_category_id, 
    standard: true, created_via_back_end: true)

Event.find_or_create_by!(name: "Pre-auth payment fail", event_category_id: payment_category_id, 
    standard: false, created_via_back_end: true, in_app_alert: true)
["Insufficient funds", "Stolen", "Tech issue"].each do |code_name|
  ReasonCode.find_or_create_by!(name: code_name)
end

reason_code = ReasonCode.find_or_create_by!(name: "GPDQ manual error")
Event.find_or_create_by!(name: "Overcharging", event_category_id: payment_category_id, standard: false)

Event.find_or_create_by!(name: "Shift starts in 10 minutes", event_category_id: doctor_shift_category_id, 
      standard: true, created_via_back_end: true, doctor_sms: true, doctor_push: true)
Event.find_or_create_by!(name: "Log on to shift", event_category_id: doctor_shift_category_id, 
      standard: true, created_via_app: true)
Event.find_or_create_by!(name: "Shift ends in 10 minutes", event_category_id: doctor_shift_category_id, 
      standard: true, created_via_app: true, doctor_push: true)
Event.find_or_create_by!(name: "Failure to log on to shift", event_category_id: doctor_shift_category_id, 
      standard: false, created_via_back_end: true, doctor_sms: true)

##### END CREATE INITIAL EVENTS #####

# Create default ReferralSetting for 1st time
ReferralSetting.create if ReferralSetting.all.count == 0

# Create default setting for GPDQ
GpdqSetting.find_or_create_by(name: "Time for doctor to confirm assigned appointment") do |setting|
  setting.value = 5
end

GpdqSetting.find_or_create_by(name: 'Expired CS Credit') do |setting|
  setting.value =  2
  setting.time_unit = 1
end

GpdqSetting.find_or_create_by(name: 'Refer bonus') do |setting|
  setting.value = 10
end

GpdqSetting.find_or_create_by(name: 'Sponsor bonus') do |setting|
  setting.value = 10
end

puts "----- Update static name for events -----"
Event.all.each do |event|
  if event.static_name.blank?
    event.update_columns(static_name: event.name)
  end
end

puts "----- Update static name for reason_code -----"
ReasonCode.all.each do |reason_code|
  if reason_code.static_name.blank?
    reason_code.update_columns(static_name: reason_code.name)
  end
end

# Create Messages for Events
puts "Create Events's Messages"
if EventMessage.count == 0
  Event.all.each do |event|
    case event.static_name
    when "Cancelation - GPDQ Error"
      reason_codes = ReasonCode.where(static_name: ["GPDQ Platform Error", "Back office mistake", "Tech error", "Unspecified"])
      reason_codes.each do |reason_code|      
        doctor_sms = case reason_code.static_name
        when "GPDQ Platform Error"
          "Dear Dr %{doctor_name}, We have cancelled your next appointment due to a technical error. Please email your GPDQ account manager for further information"
        when "Back office mistake", "Tech error", "Unspecified"
          "Yes"
        end
        EventMessage.create(event_id: event.id, reason_code_id: reason_code.id, doctor_sms: doctor_sms)
      end
    when "Patient Cancellation"
      reason_codes = ReasonCode.where(static_name: ["Patient Cancelled via app", "Patient didn't answer door",
        "Due to delay", "Due to return", "Prior to doctor confirming on route", "Serious medical issue with Patient"
      ])
      reason_codes.each do |reason_code|
        doctor_sms = nil
        patient_sms = nil
        case reason_code.static_name
        when "Patient Cancelled via app"
          doctor_sms = "Dear Dr %{doctor_name}, %{patient_name} has now cancelled booking ref %{appointment_id}. Cancellation credits may be applicable, please contact your account manager for further information"
          patient_sms = "Your cancellation was successful. A cancellation fee will be deducted from your account if the doctor has been despatched to your booking"
        when "Patient didn't answer door"
          patient_sms = "Dear %{patient_name}, your booking ref %{appointment_id} has been cancelled as the doctor was unable to locate you. As per our t&c's a cancellation fee is applicable"
        when "Due to delay"
          doctor_sms = "Dear Dr %{doctor_name}, we have now cancelled your next appt as the patient has informed us they are unable to wait any longer"
        when "Due to return"
          doctor_sms = "Dear Dr %{doctor_name}, your recent return resulted in cancellation by the patient. As per our terms and conditions a customer compensation credit is required."
        when "Prior to doctor confirming on route"
          doctor_sms = "Dear Dr %{doctor_name},  we wanted to inform you that the booking in your dashboard has now been cancelled by the patient. Please do not proceed to the appointment"
        when "Serious medical issue with Patient"
          doctor_sms = "Dear Dr %{doctor_name}, your upcoming booking has been cancelled by the patient due to a serious medical emergency."
        end
        EventMessage.create(event_id: event.id, reason_code_id: reason_code.id, doctor_sms: doctor_sms, patient_sms: patient_sms)
      end
    when "Doctor Return"
      reason_codes = ReasonCode.where(static_name: ["60 mins before ETA", "30 mins before ETA", "15 mins before ETA"])
      reason_codes.each do |reason_code|
        patient_sms = case reason_code.static_name
        when "60 mins before ETA", "30 mins before ETA"
          "dr %{doctor_name} has just informed us he/she will be unable to complete your appt due to an unexpected issue. GPDQ has found you a replacement doctor , track him/her here!"
        when "15 mins before ETA"
          "dr %{doctor_name} has just informed us he/she will be unable to complete your appt due to an unexpected issue. GPDQ has found you a replacement doctor who will arrive within 15 minutes , track him/her here!"
        end
        EventMessage.create(event_id: event.id, reason_code_id: reason_code.id, patient_sms: patient_sms)
      end
    when "Doctor delayed"
      reason_codes = ReasonCode.where(static_name: ["Late >10 minutes", "Late >20 minutes", "Late >40 minutes"])
      reason_codes.each do |reason_code|
        patient_sms = case reason_code.static_name
        when "Late >10 minutes"
          "Dr %{doctor_name} is running 10 minutes late, apologies for the inconvenience"
        when "Late >20 minutes"
          "Doctor %{doctor_name} is running late due to traffic and will be with you as soon as possible."
        when "Late >40 minutes"
          "Unfotunately Dr %{doctor_name} has been delayed due to an extention with his previous patient & will be with you shortly. A member of our team will contact you to resolve this"
        end
        EventMessage.create(event_id: event.id, reason_code_id: reason_code.id, patient_sms: patient_sms)
      end
    when "Other Customer Service Event"
      reason_codes = ReasonCode.where(static_name: [
        "ETA outside of marketing promise",
        "Inappropriate behaviour", "Inappropriate behaviour - serious", 
        "Contact with patient after appointment unless instigated by patient",
        "Offering direct services", "Inaccurately charging extra time", "Other"
      ])
      reason_codes.each do |reason_code|
        EventMessage.create(event_id: event.id, reason_code_id: reason_code.id, patient_sms: "Reactive", patient_push: "Reactive")
      end
    when "Booking confirmed"
      EventMessage.create(event_id: event.id, reason_code_id: reason_code.id, patient_sms: "Yes")
    when "Dispached to doctor"
      doctor_sms = "Dear Dr %{doctor_name}, your next appointment is waiting for acceptance."
      doctor_push = "You have a new appointment awaiting acceptance"
      doctor_push_in_app = doctor_push
      EventMessage.create(event_id: event.id, reason_code_id: reason_code.id, doctor_sms: doctor_sms, doctor_push: doctor_push, doctor_push_in_app: doctor_push_in_app)
    when "Doctor not yet confirmed on way when due"
      doctor_sms = "Dear Dr %{doctor_name}, please accept your next booking or contact us if you are unable to fulfill this"
      EventMessage.create(event_id: event.id, reason_code_id: reason_code.id, doctor_sms: doctor_sms)
    when "Doctor confirmed on way"
      patient_sms = "Hi %{patient_name}, your booking ref %{appointment_id} is  confirmed and doctor %{doctor_name} is on his way. Track him here <link>/track on link"
      EventMessage.create(event_id: event.id, reason_code_id: reason_code.id, patient_sms: patient_sms)
    when "Reminder to Doctor that appt ends in 5 minutes"
      doctor_push = "Dr %{doctor_name}, your appointment is coming to an end in 5 minutes. If you need an extension, please inform the patient"
      doctor_push_in_app = doctor_push
      EventMessage.create(event_id: event.id, reason_code_id: reason_code.id, doctor_push: doctor_push, doctor_push_in_app: doctor_push_in_app)
    when "Appointment extension in 5 min increments (increment + 3 mins is regarded as the lower increment)"
      reason_codes = ReasonCode.where(static_name: ["5 minute extension"])
      reason_codes.each do |reason_code|
        case reason_code.static_name
        when "5 minute extension"
          patient_sms = "Hi %{patient_name}, Your appointment has been extended and any applicable charges will be available to view on your receipt"
          EventMessage.create(event_id: event.id, reason_code_id: reason_code.id, patient_sms: patient_sms)
        end
      end
    when "Additional Onsite Consultation"
      reason_codes = ReasonCode.where(static_name: ["New Patient"])
      reason_codes.each do |reason_code|
        case reason_code.static_name
        when "New Patient"
          patient_sms = "You have requested an additional consultation with Dr %{doctor_name} which will be deducted from your chosen payment method"
          EventMessage.create(event_id: event.id, reason_code_id: reason_code.id, patient_sms: patient_sms)
        end
      end
    when "Appointment complete"
      patient_push = "Thanks for booking with GPDQ"
      patient_push_in_app = "Please click view details to see your appointment summary"
      EventMessage.create(event_id: event.id, patient_push: "Thanks for booking with GPDQ", patient_push_in_app: patient_push_in_app)
    end
  end
end

##### ADD MORE EVENT MESSAGES HERE IF EVENT AND REASON CODE DO NOT EXISTS IN EVENT MESSAGES TABLE #####
Event.all.each do |event|
  case event.static_name
  when "Dr Confirmed Appt started"
    patient_push = "Your appointment started, you can track your appointment time"
    patient_push_in_app = patient_push
    EventMessage.create_with(patient_push: patient_push, patient_push_in_app: patient_push_in_app).find_or_create_by(event_id: event.id)
  end
end
####################################################################################################### 

# Update 
puts "Update name for push of events"
dispached_doctor_event = Event.find_by(static_name: "Dispached to doctor")
dispached_doctor_event.update!(name_for_push: "dispached_doctor") if dispached_doctor_event && dispached_doctor_event.name_for_push.blank?
appointment_complete_event = Event.find_by(static_name: "Appointment complete")
appointment_complete_event.update!(name_for_push: "appointment_complete") if appointment_complete_event && appointment_complete_event.name_for_push.blank?
patient_cancellation_event = Event.find_by(static_name: "Patient Cancellation")
patient_cancellation_event.update!(name_for_push: "patient_cancellation") if patient_cancellation_event && patient_cancellation_event.name_for_push.blank?
dr_confirmed_appointment_start_event = Event.find_by(static_name: "Dr Confirmed Appt started")
dr_confirmed_appointment_start_event.update!(name_for_push: "dr_confirmed_appointment_started") if dr_confirmed_appointment_start_event && dr_confirmed_appointment_start_event.name_for_push.blank?

puts "Create Manual Events data"
if ManualProcessEvent.count == 0
  Event.all.each do |event|
    case event.static_name
    when "Cancelation - GPDQ Error"
      reason_codes = ReasonCode.where(static_name: ["GPDQ Platform Error", "Back office mistake", "Tech error", "Unspecified"])
      reason_codes.each do |reason_code|      
        ManualProcessEvent.create!(event_id: event.id, reason_code_id: reason_code.id)
      end
    when "Patient Cancellation"
      reason_codes = ReasonCode.where(static_name: ["Patient Cancelled via app", "Patient didn't answer door",
        "Due to delay", "Due to return", "Serious medical issue with Patient"
      ])
      reason_codes.each do |reason_code|
        ManualProcessEvent.create!(event_id: event.id, reason_code_id: reason_code.id)
      end
    when "Doctor Return"
      reason_codes = ReasonCode.where(static_name: ["30 mins before ETA", "15 mins before ETA"])
      reason_codes.each do |reason_code|
        ManualProcessEvent.create!(event_id: event.id, reason_code_id: reason_code.id)
      end
    when "Doctor delayed"
      reason_codes = ReasonCode.where(static_name: ["Late >20 minutes", "Late >40 minutes"])
      reason_codes.each do |reason_code|
        ManualProcessEvent.create!(event_id: event.id, reason_code_id: reason_code.id)
      end
    when "Other Customer Service Event"
      reason_codes = ReasonCode.where(static_name: [
        "ETA outside of marketing promise",
        "Inappropriate behaviour", "Inappropriate behaviour - serious", 
        "Contact with patient after appointment unless instigated by patient",
        "Offering direct services", "Inaccurately charging extra time", "Other"
      ])
      reason_codes.each do |reason_code|
        ManualProcessEvent.create!(event_id: event.id, reason_code_id: reason_code.id)
      end
    when "Pre-auth payment fail"
      reason_code = ReasonCode.where(static_name: "Tech issue").first
      ManualProcessEvent.create!(event_id: event.id, reason_code_id: reason_code.id)
    when "Overcharging"
      reason_code = ReasonCode.where(static_name: "GPDQ manual error").first
      ManualProcessEvent.create!(event_id: event.id, reason_code_id: reason_code.id)
    end
  end
end
