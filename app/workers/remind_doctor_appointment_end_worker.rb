class RemindDoctorAppointmentEndWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(appointment_id)
    appointment = Appointment.find_by_id(appointment_id)
    if appointment.present? && appointment.on_process?
      appointment_event = appointment.create_appointment_event(event_static_name: "Reminder to Doctor that appt ends in 5 minutes")
    end
  end
end