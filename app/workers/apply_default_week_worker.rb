class ApplyDefaultWeekWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  def perform(agency_id, doctor_id, start_time, end_time, days)
    default_periods = AgencyPeriod.where("doctor_id IS NULL").where(agency_id: agency_id, is_default_week: true)
    wday_periods = {}
    default_periods.map do |dp| 
      wday_periods[dp.week_day] = [] if wday_periods[dp.week_day].nil?
      wday_periods[dp.week_day] << dp
    end
    start_date = start_time.to_datetime
    end_date = end_time.to_datetime#start_date + 6.days#.end_of_week
    while(start_date < (end_date)) do
      wday = start_date.wday
      AgencyPeriod.where("start_at >= (?) and start_at <= (?)", start_date.beginning_of_day, start_date.end_of_day)
                  .where( week_day: start_date.wday, doctor_id: doctor_id, agency_id: agency_id).destroy_all
      wday_periods[wday].map do |ap|
        if ap.default_common_available?
          custom_status = "custom_available"
        else
          custom_status = "custom_unavailable"
        end
        
        AgencyPeriod.create(starttime_at: ap.starttime_at, 
                            week_day: wday, 
                            start_at: (start_date.strftime("%Y-%m-%d") + " #{ap.starttime_at}").to_datetime, 
                            end_at: (start_date.strftime("%Y-%m-%d") + " #{ap.starttime_at}").to_datetime + 15.minutes, 
                            agency_id: agency_id, doctor_id: doctor_id, custom_status: custom_status)
       
      end unless wday_periods[wday].nil?
      start_date += 1.day
    end
    file = Logger.new("#{Rails.root}/log/week.log")
    file.info("In worker create week11 default successfully")
    file.info("#{[agency_id, doctor_id, start_time, end_time, days].inspect}")
  end
end