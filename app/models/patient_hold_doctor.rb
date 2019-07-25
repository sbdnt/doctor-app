class PatientHoldDoctor < ActiveRecord::Base
  belongs_to :doctor
  belongs_to :patientable, polymorphic: true
end
