class TempPatient < ActiveRecord::Base
  include TransitMode

  has_many :patient_hold_doctors, as: :patientable, dependent: :destroy
  reverse_geocoded_by :latitude, :longitude do |obj,results|
    if geo = results.first
      puts "=====#{geo.postal_code.inspect}========="
      zone = geo.postal_code.to_s.split(" ").first
      puts "++++++++++++zone = #{zone.inspect} ++++++++++++++"
      zone_id = Zone.find_by_name(zone).try(:id)
      obj.zone_id = zone_id.nil? ? SubZone.find_by(name: zone).try(:zone_id) : zone_id
      obj.address = geo.address
    end
  end
  after_validation :reverse_geocode
  # after_save :return_doctor_to_available_list, if: proc{|tp| tp.changed_at_changed?}

  def save_location(lat, lng, new_address=nil, range = nil)
    if new_address.nil?
      new_address = Geocoder.address([lat, lng])
      sleep 0.2
    end
    self.address = new_address if self.address != new_address
    self.latitude = lat if self.latitude != lat
    self.longitude = lng if self.longitude != lng
    self.save
  end

  def find_doctor_around(lat, lng, address=nil, range=nil)
    if lat.present? && lng.present?
      success = true
    end
    time = 0
    begin
      if success
        # to get new location for patient
        patient = self
        # res = patient.available_etas(range)
        # doctors = []
        # res.keys.map do |dr_id|
        #   doctors << Doctor.find(dr_id).as_json
        # end
        doctors = Doctor.where("latitude IS NOT NULL and longitude IS NOT NULL and doctors.status = ? and doctors.is_hold = ?", Doctor.statuses[:approved], false).map(&:as_json)
        doctors
      else
        []
      end

    rescue
      time += 1
      retry if time < 2
      []
    end
  end

  # Updated: Thanh - Change condition filter doctors based on doctor zone eta
  def available_etas(range = nil)
    # Find available doctors
    doctors = Doctor.joins(:doctor_zones).where("doctor_zones.zone_id = ? and available = ? and latitude IS NOT NULL and longitude IS NOT NULL and doctors.status = ? and doctors.is_hold = ?", self.zone_id, true, 1, false )
    puts "doctors = #{doctors.inspect}"
    # Find covered area based on ETAs
    # available_etas = {}
    # # range = range.nil? ? 60 : range
    # doctors.map do |doctor|
    #   temp_etas = doctor.doctor_zones
    #   available_etas[doctor.id] = temp_etas unless temp_etas.blank?
    # end
    # available_etas
    doctors.map(&:id)
  end

  def get_min_eta
    doctors = self.available_etas
    etas = []
    doctors.each do |dr_id|
      pd_eta = self.get_eta_with_doctor(dr_id)
      etas << pd_eta if pd_eta.present?
    end
    min_eta = etas.blank? ? 0 : etas.min
    min_eta
  end

  def get_eta_with_doctor(doctor_id)
    doctor_appointments = Doctor.find_by(id: doctor_id).appointments.normal.where(status: [Appointment.statuses[:assigned], Appointment.statuses[:confirmed], Appointment.statuses[:on_way], Appointment.statuses[:on_process]]).order(assigned_time_at: :desc)

    if doctor_appointments.blank?
      pd_eta = self.calculate_eta_to_doctor(doctor_id)
    else
      last_appointment = doctor_appointments.first
      last_patient = last_appointment.patient
      last_appointment_end_at = last_appointment.try(:end_at)
      
      if last_appointment_end_at.present? && last_appointment_end_at > Time.zone.now
        pd_eta = self.calculate_eta_to_patient(last_patient.try(:id), doctor_id) if last_patient.present?
        pd_eta = ((last_appointment_end_at - Time.zone.now) / 60 ).round + pd_eta.to_i if pd_eta.present?
      else
        pd_eta = self.calculate_eta_to_doctor(doctor_id)
      end
    end
    pd_eta
  end

  def show_eta_with_doctor(doctor_id)
    eta = self.get_eta_with_doctor(doctor_id)
    eta.present? ? "#{eta} mins" : "N/A"
  end

  # Calculate eta from new patient to current patient
  def calculate_eta_to_patient(new_patient_id, doctor_id)

    duration = nil
    patient = Patient.find_by_id(new_patient_id)
    origin = patient.address
    return nil if origin.nil?

    destinations = self.address

    distance_record = GoogleDistanceRecord.where(origin: origin, destination: destinations, transportation: 'transit').first

    if distance_record.present?
      if !distance_record.no_result
        duration = distance_record.duration
      end
    else

      result = TransitMode.call_transit(origin, destinations, 'transit')

      if result[0] && !result[0][:no_result]
        mm, ss = result[0][:durations].divmod(60)
        duration = (ss >= 30) ? (mm + 1).to_i : mm.to_i
        km = result[0][:km].to_f
        GoogleDistanceRecord.create(origin: origin, destination: destinations, transportation: 'transit', duration: duration, distance: km)
      else
        GoogleDistanceRecord.create(origin: origin, destination: destinations, transportation: 'transit', no_result: true)
      end
    end

    duration
  end

  # Calculate eta from temp patient to doctor
  def calculate_eta_to_doctor(doctor_id)
    duration = nil
    km = nil
    counting_doctor = Doctor.find_by_id(doctor_id)

    origin = counting_doctor.address
    return nil if origin.nil?

    destinations = self.address

    distance_record = GoogleDistanceRecord.where(origin: origin, destination: destinations, transportation: 'transit').first

    if distance_record.present?
      if !distance_record.no_result
        duration = distance_record.duration
      end
    else

      result = TransitMode.call_transit(origin, destinations, 'transit')

      if result[0] && !result[0][:no_result]
        mm, ss = result[0][:durations].divmod(60)
        duration = (ss >= 30) ? (mm + 1).to_i : mm.to_i
        km = result[0][:km].to_f
        GoogleDistanceRecord.create(origin: origin, destination: destinations, transportation: 'transit', duration: duration, distance: km)
      else
        GoogleDistanceRecord.create(origin: origin, destination: destinations, transportation: 'transit', no_result: true)
      end
    end

    duration
  end

  def show_distance_with_doctor(doctor_id)
    eta = self.calculate_eta_to_doctor(doctor_id)
    eta.present? ? "#{eta} mins" : "N/A"
  end

  def find_doctor_has_min_eta
    doctors = Doctor.where(id: self.available_etas.keys)
    matrix = GoogleDistanceMatrix::Matrix.new
    res = {}
    doctors.each do |doctor|
      origin = {address: doctor.address}
      origin_lat_lng = GoogleDistanceMatrix::Place.new(origin)
      matrix.origins << origin_lat_lng
    
      dest_address = GoogleDistanceMatrix::Place.new(address: self.address)
      matrix.destinations << dest_address
      matrix_data = []
      limit = 0
      begin
        matrix.data.flatten.map{|v|
          mm, ss = v.duration_in_seconds.divmod(60)
          res[doctor.id] = (ss >= 30) ? (mm + 1) : mm
        }
      rescue
        limit += 1
        retry if limit < 2
      end
    end
    if res.present?
      res.keys[res.values.each_with_index.min.last]
    else
      nil
    end
    
  end

  def return_doctor_to_available_list
    doctor_id = self.find_doctor_has_min_eta
    doctor = Doctor.where(id: doctor_id,  is_hold: true).first
    if doctor.present?
      ReturnDoctorToAvailableListWorker.perform_at(self.changed_at + 5.minutes + 2.seconds, doctor_id, self.id)
    end
  end
  
  def generate_auth_token
    self.session_value = SecureRandom.urlsafe_base64
  end
end
