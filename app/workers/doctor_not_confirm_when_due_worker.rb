class DoctorNotConfirmWhenDueWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(appointment_id)
    appointment = Appointment.find_by_id(appointment_id)
    if appointment.doctor_id.present? && appointment.assigned? && appointment.normal?
      appointment_event = appointment.create_appointment_event(event_static_name: "Doctor not yet confirmed on way when due", options: { standard: false })
      appointment_event.send_sms_and_notification()
    end
  end
end