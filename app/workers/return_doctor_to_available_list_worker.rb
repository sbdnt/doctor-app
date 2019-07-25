# After 5m return doctor to available list
class ReturnDoctorToAvailableListWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  def perform(patient_id)
    file = Logger.new("#{Rails.root}/log/patients.log")
    begin
      patient_hold_doctors = PatientHoldDoctor.joins(:doctor).where('patient_hold_doctors.patientable_id = ? AND patient_hold_doctors.release_at IS NULL', patient_id)
      if patient_hold_doctors.any?
        patient_hold_doctors.each do |patient_hold_doctor|
          doctor = patient_hold_doctor.doctor
          doctor.update_columns(is_hold: false) if doctor.is_hold
          patient_hold_doctor.update_columns(release_at: Time.zone.now) if patient_hold_doctor.release_at.nil?
        end
      end
    rescue
      file.info("In exception!")
    end
  
    file.info("In worker Return Doctor To Available List")
  end
end