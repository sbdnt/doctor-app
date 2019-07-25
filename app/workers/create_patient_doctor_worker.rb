class CreatePatientDoctorWorker
  include Sidekiq::Worker
  # sidekiq_options queue: :api
  sidekiq_options retry: false
  
  def perform(patient_id)
    patient = Patient.find_by_id(patient_id)
    patient.save_eta_with_doctor
    
    file = Logger.new("#{Rails.root}/log/patient_doctor.log")
    file.info("In worker create patient doctor successfully")
  end
end