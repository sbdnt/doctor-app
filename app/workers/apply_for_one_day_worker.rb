class ApplyForOneDayWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  def perform(agency_id, doctor_id, start_time, end_time)
    default_periods = AgencyPeriod.where("doctor_id IS NULL").where(agency_id: agency_id, is_default_week: false)
    start_date = start_time.to_datetime
    AgencyPeriod.where("start_at >= (?) and start_at <= (?)", start_time.to_datetime.beginning_of_day, start_time.to_datetime.end_of_day)
                .where(doctor_id: doctor_id, agency_id: agency_id).destroy_all
    default_periods.map do |ap|
      if ap.default_common_available?
        AgencyPeriod.create(week_day: start_date.wday, starttime_at: ap.starttime_at, 
                           start_at: (start_date.strftime("%Y-%m-%d") + " #{ap.starttime_at}").to_datetime,
                           end_at: (start_date.strftime("%Y-%m-%d") + " #{ap.starttime_at}").to_datetime + 15.minutes,
                          agency_id: agency_id, doctor_id: doctor_id, custom_status: "custom_available")
      else
        AgencyPeriod.create(week_day: start_date.wday, starttime_at: ap.starttime_at, 
                          start_at: (start_date.strftime("%Y-%m-%d") + " #{ap.starttime_at}").to_datetime,
                          end_at: (start_date.strftime("%Y-%m-%d") + " #{ap.starttime_at}").to_datetime + 15.minutes,
                          agency_id: agency_id, doctor_id: doctor_id, custom_status: "custom_unavailable")
      end
    end
    file = Logger.new("#{Rails.root}/log/default_one_day.log")
    file.info("In worker create default_day rrr successfully")
    file.info("#{[agency_id, doctor_id, start_time, end_time].inspect}")
  end
end