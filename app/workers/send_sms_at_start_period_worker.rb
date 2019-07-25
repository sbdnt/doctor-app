class SendSmsAtStartPeriodWorker
  include Sidekiq::Worker
  # sidekiq_options queue: :api
  sidekiq_options retry: false
  
  def perform(period_id)
    period = Period.find_by_id(period_id)
    phone_mobile = period.custom_schedule.doctor.phone_number
    SMS.send_sms(phone_mobile, "Now is starting your period time!", "DoctorApp") unless phone_mobile.blank?
  end
end