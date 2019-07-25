class DoctorZone < ActiveRecord::Base
  belongs_to :doctor
  belongs_to :zone
  validates :zone_id, presence: true
  after_create :update_eta

  def update_eta
    doctor = self.doctor
    if doctor.present? && doctor.latitude.present? && doctor.longitude.present?
      doctor.create_eta_with_zone(self.zone_id)
      doctor.create_update_doctor_patient
      Doctor.reassign
    end
  end
end
