class ReasonCode < ActiveRecord::Base

  # ASSOCIATIONS
  has_many :appointment_events
  has_many :appointments, through: :appointment_events

  # SCOPES

  # VALIDATIONS
  validates :name, presence: true
end
