class DoctorReturnAppointment < ActiveRecord::Base
  belongs_to :doctor
  belongs_to :appointment

  def patient_name
    self.appointment.try(:patient).try(:fullname)
  end
end
