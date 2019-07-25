class SendResetEmailWorker
  include Sidekiq::Worker
  # sidekiq_options queue: :api
  sidekiq_options retry: false
  
  def perform(resource_id, send_to)
    if send_to == "Patient"
      puts "call send reset email to patient"
      patient = Patient.find_by(id: resource_id)
      patient.send_reset_password_instructions
      puts "end"
    else
      puts "call send reset email to doctor"
      doctor = Doctor.find_by(id: resource_id)
      doctor.send_reset_password_instructions
      puts "end"
    end
  end
end