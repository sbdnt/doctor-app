class AssignDoctorWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  def perform(appointment_id, auto_rescheduled)
    appoint = Appointment.find_by_id(appointment_id)
    appoint.assign_doctor(auto_rescheduled)
    file = Logger.new("#{Rails.root}/log/appointment.log")
    file.info("In worker create appointment successfully")
  end
end