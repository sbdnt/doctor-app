class BankHoliday < ActiveRecord::Base
  validates :event_name, :event_date, presence: true
end
