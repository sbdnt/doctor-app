class CustomSchedule < ActiveRecord::Base
  belongs_to :schedule
  has_many :periods

  after_save :send_sms_at_start_time, if: proc{|cus| cus.start_time_changed && cus.start_time.present?}
  after_update :remove_send_sms_at_start_time, if: proc{|cus| cus.start_time_changed && cus.start_time.present?}

  def send_sms_at_start_time
    SendSmsAtStartTimeWorker.perform_at(self.start_time, self.id)
  end

  def remove_send_sms_at_start_time
    RemoveSendSmsAtStartTimeWorker.new.perform(self.start_time_was, self.id)
  end
end
