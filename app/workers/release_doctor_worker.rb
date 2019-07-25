# Relase doctor to available list
#Author: Thai
class ReleaseDoctorWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  def perform(doctor_id, patient_hold_id, hold_at)
    # file = Logger.new("#{Rails.root}/log/patients.log")
    begin
      puts "running ReleaseDoctorWorker"
      patient_hold_doctor = PatientHoldDoctor.find_by_id(patient_hold_id)
      if patient_hold_doctor.present? && patient_hold_doctor.release_at.nil?
        doctor = patient_hold_doctor.doctor
        success = doctor.update_columns(is_hold: false) if doctor.id == doctor_id
        patient_hold_doctor.update(release_at: Time.zone.now)
      end
    rescue Exception => e
      # file.info("In exception!")
      # file.info(e.inspect)
    end
  
    # file.info("In worker Return Doctor To Available List")
  end
end