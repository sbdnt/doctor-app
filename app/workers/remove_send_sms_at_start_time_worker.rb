class RemoveSendSmsAtStartTimeWorker
  include Sidekiq::Worker
  # sidekiq_options queue: :api
  sidekiq_options retry: false
  
  def perform(scheduled_at, custom_schedule_id, options = {})
    a = Logger.new("#{Rails.root}/log/cron.log")
    a.info("In Remove Custom Schedule")
    # Remove form queue
    queue = Sidekiq::Queue.new
    a.info("Queue size before")
    a.info(queue.size)
    # Remove form queue
    queue.each do |job|
      job.delete if job.klass == 'SendSmsAtStartTimeWorker' && job.args[0].to_i == custom_schedule_id.to_i && job.at == scheduled_at
    end
    a.info("Queue size after")
    a.info(queue.size)

    # Remove from retries
    retries = Sidekiq::RetrySet.new
    a.info("Retries size before")
    a.info(retries.size)
    retries.each do |job|
      job.delete if job.klass == 'SendSmsAtStartTimeWorker' && job.args[0].to_i == custom_schedule_id.to_i && job.at == scheduled_at
    end
    a.info("Retries size after")
    a.info(retries.size)
    # Remove from scheduled
    delayed = Sidekiq::ScheduledSet.new
    a.info("Schedule size before")
    a.info(delayed.size)
    delayed.each do |job|
      job.delete if job.klass == 'SendSmsAtStartTimeWorker' && job.args[0].to_i == custom_schedule_id.to_i && job.at == scheduled_at
    end
    a.info("Schedule size after")
    a.info(delayed.size)
  end
end