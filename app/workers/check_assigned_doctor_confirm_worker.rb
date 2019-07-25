class CheckAssignedDoctorConfirmWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  def perform(appoint_id, patient_id, doctor_id)
    # file = Logger.new("#{Rails.root}/log/patients.log")
    begin
      patient = Patient.find_by_id(patient_id)
      appoint = patient.appointments.find_by_id(appoint_id)
      if appoint
        # if (patient.changed_at + 5.minutes) < Time.zone.now 
        #   # Return to available list doctors if confirm after 5m
        #   ReturnDoctorToAvailableListWorker.new.perform(doctor_id, patient_id)
        #   # Find new doctor to reassign
        #   doctor_id = patient.algorithm_optimisation_assignment(appointment_id: appoint.id) if patient
        # end
        if patient && doctor_id.nil?
          doctor_id = patient.algorithm_optimisation_assignment(appointment_id: appoint.id) if patient
        end
        assigned_time_at = doctor_id.nil? ? nil : Time.zone.now
        doctor = Doctor.find_by_id(doctor_id)
        agency_id = doctor.try(:agency_id)
        apt_status = doctor_id.nil? ? 0 : 4
        puts "=============="
        puts "doctor_id = #{doctor_id.inspect}"
        puts "apt_status = #{apt_status}"
        # file.info("In exception!")
        # file.info("==============")
        # file.info("doctor_id = #{doctor_id.inspect}")
        # file.info("apt_status = #{apt_status}")
        # Assign doctor 's HOLD status if confirm within 5m or new doctor
        appoint.update_attributes(doctor_id: doctor_id, agency_id: agency_id, assigned_time_at: assigned_time_at, status: apt_status)
        ReturnDoctorToAvailableListWorker.new.perform(patient_id)
        puts "FINAL APT = #{appoint.inspect}"
        # file.info("FINAL APT = #{appoint.inspect}")
        puts "=============="
      end
    rescue
      # file.info("In exception!")
    end
  
    # file.info("In worker Return Doctor To Available List")
  end
end