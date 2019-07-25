class ApplySchedule < ActiveRecord::Base
  belongs_to :doctor
  belongs_to :agency
end
