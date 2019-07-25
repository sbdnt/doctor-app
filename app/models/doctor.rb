class Doctor < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  include SMS
  include TransitMode
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  # Relation
  belongs_to :agency
  has_many :doctor_zones, dependent: :destroy
  has_many :agency_periods, dependent: :destroy
  has_many :apply_schedules, dependent: :destroy
  has_many :patient_doctors, dependent: :destroy
  has_many :appointments, dependent: :destroy
  has_many :doctor_return_appointments, dependent: :destroy
  has_many :patient_hold_doctors, dependent: :destroy
  has_many :sms_systems, dependent: :destroy
  accepts_nested_attributes_for :doctor_zones, :allow_destroy => true


  validates_associated :doctor_zones
  mount_uploader :avatar, PhotoUploader
  mount_uploader :gmc_cert, FileUploader
  mount_uploader :dbs_cert, FileUploader
  mount_uploader :mdu_mps_cert, FileUploader
  mount_uploader :passport, PhotoUploader
  mount_uploader :last_appraisal_summary, FileUploader
  mount_uploader :hepatitis_b_status, FileUploader
  mount_uploader :child_protection_cert, FileUploader
  mount_uploader :adult_safeguarding_cert, FileUploader
  mount_uploader :reference_gp, FileUploader
  validates :name,
          # :avatar, :phone_mobile, :phone_landline, :gmc_cert, :dbs_cert,
          # :mdu_mps_cert, :passport, :last_appraisal_summary, :hepatitis_b_status,
          # :child_protection_cert, :adult_safeguarding_cert, :reference_gp,
          :presence => true
  validates :reason, presence: true, if: proc {|d| d.rejected?}
  validate :check_doctor_zones
  validate :check_start_location
  validate :check_zone_for_uniqueness

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, presence: true
  validates :role, presence: true
  validates :platform, inclusion: { in: %w(ios android),
    message: "%{value} is not a valid platform" }, allow_blank: true

  validates :gmc_cert, presence: true, if: proc { |d| d.gmc_cert_exp == "" || d.gmc_cert_exp.present?}
  validates :gmc_cert_exp, presence: true, if: proc { |d| d.gmc_cert == "" || d.gmc_cert.present?}

  validates :dbs_cert, presence: true, if: proc { |d| d.dbs_cert_exp == "" || d.dbs_cert_exp.present?}
  validates :dbs_cert_exp, presence: true, if: proc { |d| d.dbs_cert == "" || d.dbs_cert.present?}

  validates :mdu_mps_cert, presence: true, if: proc { |d| d.mdu_mps_cert_exp == "" || d.mdu_mps_cert_exp.present?}
  validates :mdu_mps_cert_exp, presence: true, if: proc { |d| d.mdu_mps_cert == "" || d.mdu_mps_cert.present?}

  validates :last_appraisal_summary, presence: true, if: proc { |d| d.last_appraisal_summary_exp == "" || d.last_appraisal_summary_exp.present?}
  validates :last_appraisal_summary_exp, presence: true, if: proc { |d| d.last_appraisal_summary == "" || d.last_appraisal_summary.present?}

  validates :hepatitis_b_status, presence: true, if: proc { |d| d.hepatitis_b_status_exp == "" || d.hepatitis_b_status_exp.present?}
  validates :hepatitis_b_status_exp, presence: true, if: proc { |d| d.hepatitis_b_status == "" || d.hepatitis_b_status.present?}

  validates :child_protection_cert, presence: true, if: proc { |d| d.child_protection_cert_exp == "" || d.child_protection_cert_exp.present?}
  validates :child_protection_cert_exp, presence: true, if: proc { |d| d.child_protection_cert == "" || d.child_protection_cert.present?}

  validates :adult_safeguarding_cert, presence: true, if: proc { |d| d.adult_safeguarding_cert_exp == "" || d.adult_safeguarding_cert_exp.present?}
  validates :adult_safeguarding_cert_exp, presence: true, if: proc { |d| d.adult_safeguarding_cert == "" || d.adult_safeguarding_cert.present?}

  ### CALLBACKS ###
  after_update :send_email_approved, if: proc{|a| a.status_changed?}
  after_create :send_email_approved, if: proc{|a| a.approved?}
  # after_save :create_doctor_zones, if: Proc.new{|doctor| doctor.address.present? && doctor.address_changed?}
  after_save :reassign_doctor_to_appointment, if: Proc.new{|doctor| doctor.address.present? && doctor.address_changed?}
  after_save :create_doctor_patient_worker, if: Proc.new{|doctor| doctor.address.present? && (doctor.address_changed? || doctor.transportation_changed? || doctor.is_transit_changed?) }

  before_save :generate_auth_token, if: proc { |doctor| doctor.new_record?}

  ### ENUMS ###
  enum status: {pending: 0, approved: 1, rejected: 2}
  enum role: {"GP" => 1, "Locum Agency" => 2, "Current GP Services Provider" => 3}
  enum gender: {"Female" => 1, "Male" => 2}
  
  # geocoded_by :address   # can also be an IP address
  # after_validation :geocode

  def self.modify_status
    {approved: 1, rejected: 2}
  end
  def active_for_authentication?
    super && self.approved? # i.e. super && self.is_active
  end

  def inactive_message
    "Sorry, this account has not been approved!"
  end

  def send_email_approved
    if self.approved?
      DoctorMailer.approved_doctor(self).deliver_now
    elsif self.rejected?
      DoctorMailer.reject_doctor(self).deliver_now
    end
  end

  def save_eta_with_zones
    origin = self.address
    
    zones = Zone.where(:id => self.doctor_zones.map(&:zone_id))
    zones.each do |zone|

      duration = nil
      destinations = zone.address
      next if destinations.nil?

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

      doctor_zone = DoctorZone.find_by_doctor_id_and_zone_id(self.id, zone.id)
      if doctor_zone.present?
        doctor_zone.update_attributes(eta: duration) if duration.present? && doctor_zone.eta != duration
      else
        DoctorZone.create(doctor_id: self.id, zone_id: zone_id, eta: duration)
      end
    end

  end

  def create_eta_with_zone(zone_id)
    duration = nil
    origin = self.address

    zone = Zone.find_by_id(zone_id)
    destinations = zone.address
    return if destinations.nil?

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

    doctor_zone = DoctorZone.find_by_doctor_id_and_zone_id(self.id, zone_id)
    if doctor_zone.present?
      doctor_zone.update_attributes(eta: duration) if doctor_zone.eta != duration
    else
      DoctorZone.create(doctor_id: self.id, zone_id: zone_id, eta: duration)
    end
  end

  def create_update_doctor_patient

    origin = self.address
    
    patients = Patient.where(zone_id: self.doctor_zones.map(&:zone_id))
    patients.each do |patient|
      duration = nil
      km = nil
      destinations = patient.address
      next if destinations.nil?

      doctor_appointment = self.appointments.active.where(patient_id: patient.id).first

      transport_methods = ['transit']
      if doctor_appointment.present? && ['driving','walking'].include?(doctor_appointment.transport)
        transport_methods << doctor_appointment.transport
      end

      transport_methods.each do |transport_method|

        distance_record = GoogleDistanceRecord.where(origin: origin, destination: destinations, transportation: transport_method).first

        if distance_record.present?
          if !distance_record.no_result
            duration = distance_record.duration
            km = distance_record.distance
          end
        else

          result = TransitMode.call_transit(origin, destinations, transport_method)

          if result[0] && !result[0][:no_result]
            mm, ss = result[0][:durations].divmod(60)
            duration = (ss >= 30) ? (mm + 1).to_i : mm.to_i
            km = result[0][:km].to_f
            GoogleDistanceRecord.create(origin: origin, destination: destinations, transportation: transport_method, duration: duration, distance: km)
          else
            GoogleDistanceRecord.create(origin: origin, destination: destinations, transportation: transport_method, no_result: true)
          end
        end

        patient_doctor = PatientDoctor.find_by_patient_id_and_doctor_id_and_transport(patient.id, self.id, transport_method)
        if duration.present?
          if patient_doctor.nil?
            PatientDoctor.create(patient_id: patient.id, doctor_id: self.id, transport: transport_method, eta: duration, km: km)
          else
            patient_doctor.update_attributes(eta: duration, km: km)
          end
        else
          patient_doctor.destroy if patient_doctor.present?
        end
      end
    end

  end

  def doctor_zone_list
    if self.doctor_zones.present?
      self.doctor_zones.includes(:zone).map{ |z| z.zone.present? ? z.zone.name : '' }.join(', ')
    else
      'N/A'
    end
  end

  def get_document_link(attributes)
    if self.try(attributes).present?
      self.try(attributes).try(:url).split("/").last
    end
  end

  def update_location(latitude, longitude)
    self.update_attributes(latitude: latitude, longitude: longitude)
  end

  def self.reassign
    appointments = Appointment.normal.where("doctor_id IS NULL")
    if appointments.any?
      appointments.each do |appointment|
        # Find optimisation doctor
        doctor_id = appointment.patient.algorithm_optimisation_assignment(appointment_id: appointment.id)
        appointment.update_attributes(doctor_id: doctor_id, assigned_time_at: Time.zone.now, status: Appointment.statuses[:assigned]) unless doctor_id.nil?
      end
    end
  end

  def reassign_doctor_to_appointment
    ReassignDoctorToAppointmentWorker.new.perform()
  end

  def as_json_view_profile(options = {})
    {
      uid: id,
      about: description,
      avatar_url: self.avatar_url.nil? ? "http://healthathomes.com/wp-content/uploads/bb_florida-ent-doctor.png" : self.avatar_url,
      fullname: name
    }
  end

  def as_json_available_doctor
    {
      uid: self.id,
      email: self.email,
      latitude: latitude,
      longitude: longitude
    }
  end

  def check_doctor_zones
    if self.doctor_zones.blank?
      errors[:base] << "You must choose at least one zone covered"
    end
  end

  def check_start_location
    selected_zone_ids = self.doctor_zones.map(&:zone_id).uniq
    start_location_id = Zone.find_by_name(self.default_start_location).try(:id)
    unless selected_zone_ids.include?(start_location_id)
      errors[:base] << "You must select the default start location in the selected zone covered list"
    end
  end

  def check_zone_for_uniqueness
    if self.doctor_zones.present?
      group_zone = self.doctor_zones.group_by(&:zone_id)
      group_zone.values.each do |list_zone|
        if list_zone.count > 1
          errors.add(:doctor_zones, 'are duplicated') and return
        end
      end
    end
  end

  def create_doctor_zones
    p "================ Running Worker: create_doctor_zones ================"
    CreateDoctorZoneWorker.new.perform(self.id)
  end

  def create_doctor_patient_worker
    p "================ Running Worker: create_doctor_patient_worker ================"
    # CreateDoctorPatientWorker.new.perform(self.id)
    self.create_update_doctor_patient
    self.update_doctor_appointments
  end

  def as_json(options = {})
    current_appointment = self.appointments.active.order('assigned_time_at asc').first
    transportation = current_appointment.try(:transport) || 'transit'
    # transport = transportation.blank? ? "driving" : transportation
    # transport = "transit" if is_transit
    {
      :uid => id,
      :email => email,
      :auth_token => auth_token,
      :avatar_url => self.avatar_url.nil? ? "http://healthathomes.com/wp-content/uploads/bb_florida-ent-doctor.png" : self.avatar_url,
      :fullname => name,
      :phone_number => phone_number,
      :phone_landline => phone_landline,
      :latitude => latitude, 
      :longitude => longitude,
      :first_name => first_name,
      :last_name => last_name,
      :gender => gender,
      :company_name => company_name,
      :is_working => available,
      :role => role,
      :status => status,
      :working_zones => doctor_zone_list,
      :default_start_location => default_start_location,
      :about => description,
      :transportation => transportation
    }
  end

  def info_as_json
    current_appointment = self.appointments.active.order('assigned_time_at asc').first
    transportation = current_appointment.try(:transport) || 'transit'
    # transportation = "driving" unless transportation.present?
    # transportation = "transit" if is_transit
    {
      :uid => id,
      :email => email,
      :avatar_url => self.avatar_url.nil? ? "http://healthathomes.com/wp-content/uploads/bb_florida-ent-doctor.png" : self.avatar_url,
      :fullname => name,
      :phone_number => phone_number,
      :phone_landline => phone_landline,
      :latitude => latitude, 
      :longitude => longitude,
      :first_name => first_name,
      :last_name => last_name,
      :gender => gender,
      :company_name => company_name,
      :is_working => available,
      :role => role,
      :status => status,
      :working_zones => doctor_zone_list,
      :default_start_location => default_start_location,
      :about => description,
      :transportation => transportation
    }
  end

  def as_json_track_doctor(options={})
    {
      uid: id,
      latitude: latitude,
      longitude: longitude,
      avatar_url: self.avatar_url.nil? ? "http://healthathomes.com/wp-content/uploads/bb_florida-ent-doctor.png" : self.avatar_url,
      fullname: name
    }
  end

  def find_doctors_around(range: nil)
    time = 0
    begin
      doctors_before_filter = Doctor.includes(:doctor_zones).where(available: true, status: Doctor.statuses[:approved], is_hold: false)
                              .where.not(latitude: nil, longitude: nil)

      range ||= 60
      doctors = []
      doctors_before_filter.each do |doctor|
        # doctor_zones = doctor.doctor_zones.select { |dz| (!dz.eta.nil? && dz.eta.between?(1, 59)) }
        doctors << doctor.info_as_json if doctor.doctor_zones.any?
      end
    rescue
      time += 1
      retry if time < 2
      []
    end
  end

  def unfinished_appointments
    self.appointments.normal.where(status: [Appointment.statuses['on_way'], Appointment.statuses['on_process'], Appointment.statuses['confirmed'], Appointment.statuses['assigned']]).order('end_at desc')
  end

  def next_available
    unfinished_appointment = self.unfinished_appointments.first
    end_at = unfinished_appointment.try(:end_at)
    if end_at.present? && end_at >= Time.zone.now
      return end_at.strftime("%m-%d %H:%M")
    else
      return 'Now'
    end
  end

  def available_location
    unfinished_appointment = self.unfinished_appointments.first
    end_at = unfinished_appointment.try(:end_at)
    if unfinished_appointment.present? && end_at.present? && end_at >= Time.zone.now
      address = unfinished_appointment.patient.try(:address)
    else
      address = self.address
    end
    address ||= 'GPS'
    return address
  end

  def get_zone_eta(zone_id)
    zone_eta = 'N/A'
    doctor_zone = DoctorZone.where(doctor_id: self.id, zone_id: zone_id).first
    if doctor_zone.present?
      eta = doctor_zone.eta
      if eta.present?
        zone_eta = "#{eta} #{eta > 0 ? 'mins' : 'min'}"
      end
    end

    zone_eta
  end

  def eta_to_patient(patient)
    return nil unless patient.present?

    doctor_eta = nil
    unfinished_appointment = self.unfinished_appointments.first

    doctor_appointment = self.appointments.active.where(patient_id: patient.id).first
    appointment_transport = doctor_appointment.try(:transport) || 'transit'
    pd_eta = PatientDoctor.where(doctor_id: self.id, patient_id: patient.id, transport: appointment_transport).first.try(:eta)
    if unfinished_appointment.nil?
      doctor_eta = pd_eta.to_i if pd_eta.present?
    else
      last_patient = unfinished_appointment.patient
      last_appointment_end_at = unfinished_appointment.end_at
      new_pd_eta = patient.calculate_eta_to_patient(last_patient.id, self.id)
      if pd_eta.present?
        if last_appointment_end_at > Time.zone.now
          doctor_eta = ((last_appointment_end_at - Time.zone.now) / 60 ).round + new_pd_eta.to_i
        else
          doctor_eta = pd_eta.to_i
        end
      end
    end

    doctor_eta
  end

  def show_eta_to_patient(patient)
    eta_pt = self.eta_to_patient(patient)
    if eta_pt.present?
      "#{eta_pt} mins"
    else
      "N/A"
    end
  end

  def get_held_patient
    patient_name = 'N/A'
    if self.is_hold
      patient_hold_doctor = self.patient_hold_doctors.where(release_at: nil).first
      patient = patient_hold_doctor.patientable if patient_hold_doctor.present?
      patient_name = patient.fullname if patient.present?
    end
    patient_name
  end

  def get_transportation_method
    if self.is_transit
      'transit'
    else
      self.transportation || 'transit'
    end
  end

  def has_running_appointment?
    if self.appointments.normal.where(status: [Appointment.statuses[:on_way], Appointment.statuses[:on_process]]).count > 0
      return true
    else
      return false
    end
  end

  def update_doctor_appointments
    appointments = self.reload.appointments.active.order('assigned_time_at asc')

    previous_appointment = nil
    appointments.each_with_index do |appointment, index|
      previous_appointment = appointments[index - 1] if index > 0
      appointment.update_appointment_time(previous_appointment.try(:id), 0)
    end
  end

  protected

  def generate_auth_token
    self.auth_token = SecureRandom.urlsafe_base64
    generate_auth_token if self.class.exists?(auth_token: self.auth_token)
  end
end
