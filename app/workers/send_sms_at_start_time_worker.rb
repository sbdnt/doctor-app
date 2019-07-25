class SendSmsAtStartTimeWorker
  include Sidekiq::Worker
  # sidekiq_options queue: :api
  sidekiq_options retry: false
  
  def perform(custom_schedule_id)
    cus_schedule = CustomSchedule.find_by_id(custom_schedule_id)
    phone_mobile = cus_schedule.doctor.phone_number
    SMS.send_sms(phone_mobile, "Now is starting your working day!", "DoctorApp") unless phone_mobile.blank?
  end
end