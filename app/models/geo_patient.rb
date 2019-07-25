## To save zone corresponding with  address
class GeoPatient < ActiveRecord::Base
  self.table_name = "patients"
  reverse_geocoded_by :latitude, :longitude do |obj,results|
    if geo = results.first
      puts "=====#{geo.postal_code.inspect}========="
      zone = geo.postal_code.to_s.split(" ").first
      puts "++++++++++++zone = #{zone.inspect} ++++++++++++++"
      zone_id = Zone.find_by_name(zone).try(:id)
      obj.zone_id = zone_id.nil? ? SubZone.find_by(name: zone).try(:zone_id) : zone_id
      # obj.address = geo.address
    end
  end
  after_validation :reverse_geocode
  after_save :update_eta_and_hold_doctor
  # after_save :keep_hold_doctor_status, if: proc { |patient| patient.address_changed? }
  # after_save :create_patient_doctor, if: proc {|patient| patient.zone_id_changed? || patient.address_changed?}

  def save_location(lat, lng, new_address=nil, range = nil)
    if new_address.nil?
      new_address = Geocoder.address([lat, lng])
      sleep 0.2
    else
      new_address = URI.unescape(new_address)
    end

    self.address = new_address if self.address != new_address
    self.latitude = lat if self.latitude != lat
    self.longitude = lng if self.longitude != lng
    self.save
  end

  def update_eta_and_hold_doctor
    if self.zone_id_changed? || self.address_changed?
      self.create_patient_doctor
    end

    if self.address_changed?
      self.keep_hold_doctor_status
    end
  end

  def create_patient_doctor
    # CreatePatientDoctorWorker.new.perform(self.id)
    patient = Patient.find_by_id(self.id)
    patient.save_eta_with_doctor
  end

  def keep_hold_doctor_status
    p '------------ holding doctor for patient'
    patient = Patient.find_by_id(self.id)
    patient_appointments = patient.appointments.active
    if patient_appointments.blank?
      holding_doctor_patients = patient.patient_hold_doctors.joins(:doctor).where('patient_hold_doctors.release_at IS NULL AND doctors.is_hold = ?', true)

      if holding_doctor_patients.any?
        holding_doctor_patients.each do |holding_doctor_patient|
          holding_doctor = holding_doctor_patient.doctor
          holding_doctor.update_columns(is_hold: false)
          holding_doctor_patient.update(release_at: Time.zone.now) if holding_doctor_patient.release_at.nil?
        end
      end

      patient.reload
      doctor_id = patient.algorithm_optimisation_assignment if patient
      if doctor_id
        doctor = Doctor.find_by_id(doctor_id)
        patient_hold = patient.patient_hold_doctors.create(doctor_id: doctor_id, hold_at: Time.zone.now) if doctor
        if patient_hold
          doctor.update_columns(is_hold: true)
          puts "--------Schedule ReleaseDoctorWorker ---------"
          ReleaseDoctorWorker.perform_at(patient_hold.hold_at + 5.minutes, doctor_id, patient_hold.id, patient_hold.hold_at)
        end
      end
    end
  end
end
