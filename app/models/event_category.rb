class EventCategory < ActiveRecord::Base

  # ASSOCIATIONS
  has_many :events

  # SCOPES

  # VALIDATIONS
  validates :name, presence: true
end
