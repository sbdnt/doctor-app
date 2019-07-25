class Event < ActiveRecord::Base

  # ASSOCIATIONS
  belongs_to :event_category
  has_many :appointment_events
  has_many :appointments, through: :appointment_events
  has_many :sms_systems, dependent: :destroy

  # SCOPES

  # VALIDATIONS
  validates :name, presence: true
  validates :name, uniqueness: true
  validates :standard, :created_via_back_end, :created_via_app,
    :doctor_sms, :doctor_push, :patient_sms, :patient_push, :in_app_alert,
    inclusion: { in: [true, false], message: "%{value} is not a valid value (true or false)" },
    allow_blank: true
end
