class EventMessage < ActiveRecord::Base

  # ASSOCIATIONS
  belongs_to :event
  belongs_to :reason_code

  # SCOPES

  # VALIDATIONS
  validates :event_id, presence: true

  # Instance methods should follow Alphabet rules
end
