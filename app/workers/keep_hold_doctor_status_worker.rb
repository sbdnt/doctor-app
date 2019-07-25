class KeepHoldDoctorStatusWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  def perform(patient_id)
    # file = Logger.new("#{Rails.root}/log/patients.log")
    puts "------- Running KeepHoldDoctorStatusWorker ----------"
    patient = Patient.find_by_id(patient_id)
    holding_doctor_patients = patient.patient_hold_doctors.joins(:doctor).where('patient_hold_doctors.release_at IS NULL AND doctors.is_hold = ?', true)

    if holding_doctor_patients.any?
      holding_doctor_patients.each do |holding_doctor_patient|
        holding_doctor = holding_doctor_patient.doctor
        holding_doctor.update_columns(is_hold: false)
        holding_doctor_patient.update(release_at: Time.zone.now) if holding_doctor_patient.release_at.nil?
      end
    end

    doctor_id = patient.algorithm_optimisation_assignment if patient
    if doctor_id
      doctor = Doctor.find_by_id(doctor_id)
      # file.info("is hold #{doctor.is_hold}")
      patient_hold = patient.patient_hold_doctors.create(doctor_id: doctor_id, hold_at: Time.zone.now)
      if patient_hold
        doctor.update_columns(is_hold: true)
        puts "--------Schedule ReleaseDoctorWorker ---------"
        ReleaseDoctorWorker.perform_at(patient_hold.hold_at + 5.minutes, doctor_id, patient_hold.id, patient_hold.hold_at)
        # file.info("is hold after save #{doctor.is_hold}")
      end
    end
    # file.info("doctor id #{doctor_id}")
    # file.info("In worker Keep hold doctor status")
  end
end