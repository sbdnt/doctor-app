module WorkerUtility
  def self.kill_worker(jid)
    r = Sidekiq::ScheduledSet.new
    jobs = r.select{|job| job.jid == jid}
    jobs.each(&:delete)
  end
end