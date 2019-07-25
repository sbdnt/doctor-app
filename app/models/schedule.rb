class Schedule < ActiveRecord::Base
  belongs_to :agency
  has_many :periods, dependent: :destroy
  has_one :custom_schedule
end
