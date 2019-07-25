class ApplyDefaultDayWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  def perform(agency_id, doctor_id, start_time, end_time, days)
    default_periods = AgencyPeriod.where("doctor_id IS NULL").where(agency_id: agency_id, is_default_week: false)
    file = Logger.new("#{Rails.root}/log/default_day.log")
    wday = wday.present? ? wday.to_i : nil
    is_default_week = wday.present? ? true : false
    start_date = start_time.to_datetime
    end_date = end_time.to_datetime
    while(start_date < end_date) do
      if days.include?(start_date.wday.to_s)
        AgencyPeriod.where("start_at >= (?) and start_at <= (?)", start_date.beginning_of_day, start_date.end_of_day).
                     where( week_day: start_date.wday, doctor_id: doctor_id, agency_id: agency_id).destroy_all
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
      end
      start_date += 1.day
    end
    
    file.info("In worker create default_day rrr successfully")
    file.info("#{[agency_id, doctor_id, start_time, end_time, days].inspect}")
  end
end