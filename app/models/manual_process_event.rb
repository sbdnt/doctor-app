class ManualProcessEvent < ActiveRecord::Base
  # ASSOCIATIONS
  belongs_to :event
  belongs_to :reason_code

  # SCOPES

  # VALIDATIONS
  validates :event, presence: true
  validates :manual_process, inclusion: { in: [true, false], message: "%{value} is not a valid value (true or false)" }

  # Instance methods should follow Alphabet rules
end
