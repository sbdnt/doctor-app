class Period < ActiveRecord::Base
  belongs_to :schedule
  belongs_to :custom_schedule

  after_save :send_sms_at_start_period, if: proc{|p| p.doctor_status_changed?}
  after_update :remove_send_sms_at_start_period, if: proc {|p| p.doctor_status_changed?}
  enum status: {unavailable: 0, available: 1}
  BOOL = {"true" => true, "false" => false}

  def send_sms_at_start_period
    periods = self.custom_schedule.periods
    periods.each_with_index do |period, index|
      if periods[index].status == 0 && periods[index + 1].status == 1
        SendSmsAtStartPeriodWorker.perform_at(period.start_at, period.id)
      end
    end
  end

  def remove_send_sms_at_start_period
    periods = self.custom_schedule.periods
    periods.each_with_index do |period, index|
      if periods[index].status_was == 0 && periods[index + 1].status_was == 1
        RemoveSendSmsAtStartPeriodWorker.new.perform(period.start_at, period.id)
      end
    end
  end

  def as_json(options = {})
    colors = {0 => "grey", 1 => "grey", "default_specific_unavailable" => "red",
      "default_specific_available" => "green", "custom_unavailable" => "red", "custom_available" => "green",
      "default_common_unavailable" => "red", "default_common_available" => "green", nil => "grey"}
    from_date = options[:start_date].to_datetime
    start_at = Date.new(from_date.year, from_date.month, from_date.day).strftime("%Y-%m-%d") + self.start_at.strftime(" %H:%M:%S")

    if options[:for_week] == false
        a_period = AgencyPeriod.where(is_default_week: false, starttime_at: self.start_at.strftime("%H:%M"), agency_id: options[:agency_id]).first
        
    else
      a_period = AgencyPeriod.where(week_day: options[:wday].to_i, is_default_week: options[:for_week], starttime_at: self.start_at.strftime("%H:%M"), agency_id: options[:agency_id]).first
      
    end
    
    status = a_period.nil? ? self.agency_status : a_period.default_common_status
    start = Date.new(from_date.year, from_date.month, from_date.day).strftime("%Y-%m-%d") + self.start_at.strftime(" %H:%M") 
    {
      title: "",
      start: start,#Date.new(2015, 6, options[:date].to_i).strftime("%Y-%m-%d") + self.start_at.strftime(" %H:%M"),#self.start_at.strftime("%Y-%m-%d %H:%M"),#'2015-06-5 11:00:00'
      wday: start.to_datetime.wday,
      url: "",
      status: status,
      color: colors[status],
      id: self.id,
      agency_period_id: a_period.try(:id)
    }
  end

  def as_json_doctor_custom(options = {})
    file = Logger.new("#{Rails.root}/log/default_day.log")
    colors = {0 => "red", 1 => "green", "default_specific_unavailable" => "red",
      "default_specific_available" => "green", "custom_unavailable" => "red", "custom_available" => "green",
      "default_common_unavailable" => "red", "default_common_available" => "green", nil => "grey"}

    from_date = options[:start_date].to_datetime
    file.info(from_date)
    begin_day = from_date.utc.beginning_of_day
    end_day = from_date.utc.end_of_day
    a_period = AgencyPeriod.where("start_at >= (?) and start_at <= (?)", begin_day, end_day)
                           .where(starttime_at: self.start_at.strftime("%H:%M"), agency_id: options[:agency_id], doctor_id: options[:doctor_id]).first
    
    aa = AgencyPeriod.where("start_at >= (?) and start_at <= (?)", begin_day, end_day).count
    status = a_period.nil? ? self.agency_status : a_period.custom_status

    start = a_period.nil? ? Date.new(from_date.year, from_date.month, from_date.day).strftime("%Y-%m-%d") + self.start_at.strftime(" %H:%M") : a_period.start_at.strftime("%Y-%m-%d %H:%M")
    appoint = Appointment.where("assigned_time_at >= (?) and assigned_time_at <= (?)", start.to_datetime, start.to_datetime + 15.minutes)
                         .where(agency_id: options[:agency_id], doctor_id: options[:doctor_id]).first
    patient = appoint.nil? ? "" : "Appointment with #{appoint.patient.name}"

    {
      title: patient,
      start: start,#Date.new(2015, 6, options[:date].to_i).strftime("%Y-%m-%d") + self.start_at.strftime(" %H:%M"),#self.start_at.strftime("%Y-%m-%d %H:%M"),#'2015-06-5 11:00:00'
      url: "",
      status: status,
      color: colors[status],
      id: a_period.nil? ? self.id : a_period.id,
      appointment_id: appoint.try(:id),
      agency_period_id: a_period.try(:id)
    }
  end

end
