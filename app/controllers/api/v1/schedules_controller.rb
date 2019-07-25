class Api::V1::SchedulesController < Api::V1::BaseApiController
  before_filter :api_authenticate_agency!
  #before_filter :api_authenticate_doctor!
  api :GET, '/schedules/load_default_schedules', 'Get default schedules'
  param_group :default, Api::V1::Docs::CalendarsDoc
  example Api::V1::Docs::CalendarsDoc.load_default_schedules_desc
  def load_default_schedules

    #end_date = params[:end_time].blank? ? start_date + 1.day : params[:end_time].to_datetime
    res = []
    if params[:default_week] == "true"
      start_date = params[:start_time].blank? ? Date.today.beginning_of_week + 1.day : params[:start_time].to_datetime
      end_date = params[:end_time].blank? ? start_date.end_of_week + 1.day : params[:end_time].to_datetime
    else
      start_date = params[:start_time].blank? ? Date.today : params[:start_time].to_datetime
      end_date = start_date
    end
    while(start_date <= end_date) do
      res << Period.order("start_at").map{|p| p.as_json({wday: start_date.wday,
                                                        start_date: start_date.to_s,
                                                        agency_id: current_agency.id,
                                                        for_week: params[:default_week],
                                                        changed_by: "default_common_status"})}
      start_date += 1.day
    end
    render json: res.uniq.flatten
  end

  api :GET, '/schedules/load_custom_calendars', 'Get default schedules'
  param_group :calendars, Api::V1::Docs::CalendarsDoc
  example Api::V1::Docs::CalendarsDoc.load_custom_calendars_desc
  def load_custom_calendars
      if current_agency
        agency_id = current_agency.try(:id)
      else
        agency_id = current_doctor.agency_id
      end
      session[:doctor_id] = params[:doctor_id]
      if params[:default_week] == "true"
        start_date = params[:start_time].blank? ? Date.today.beginning_of_week + 1.day : params[:start_time].to_datetime
        end_date = params[:end_time].blank? ? start_date.end_of_week + 1.day : params[:end_time].to_datetime
      else
        start_date = params[:start_time].blank? ? Date.today : params[:start_time].to_datetime
        end_date = start_date
      end
      res = []
      if TimeDifference.between(start_date, end_date).in_days.to_i <=1
        for_week = false
      else
        for_week = true
      end
      while(start_date <= end_date) do
        options = {wday: start_date.wday, start_date: start_date.to_s, agency_id: agency_id,
                   doctor_id: params[:doctor_id], changed_by: "custom_status", for_week: for_week}
        res << Period.order("start_at").map{|p| p.as_json_doctor_custom(options).merge({doctor_id: params[:doctor_id], changed_by: "custom_status"})}
        start_date += 1.day
      end
      render json: res.uniq.flatten
  end

  api :PUT, '/schedules/apply_default_schedule', 'Get default schedules'
  param_group :apply_default, Api::V1::Docs::CalendarsDoc
  example Api::V1::Docs::CalendarsDoc.apply_default_schedule_desc
  def apply_default_schedule
    start_date = params[:start_time].blank? ? Date.today : params[:start_time].to_datetime
    end_date = params[:end_time].blank? ? start_date : params[:end_time].to_datetime
    res = []
    if TimeDifference.between(start_date, end_date).in_days.to_i <=1
      for_week = false
    else
      for_week = true
    end
    doctor_id = params[:doctor_id]
    if current_agency
      agency_id = current_agency.id
      doctor_id = params[:doctor_id]
    else
      doctor_id = current_doctor.id
      agency_id = current_doctor.agency.try(:id)
    end
    if for_week
      if params[:is_default_week] == true || params[:is_default_week] == "true"
        ApplyDefaultWeekWorker.new.perform(agency_id, doctor_id, start_date.to_s, end_date.to_s, params[:selected_days])
      else
        ApplyDefaultDayWorker.new.perform(agency_id, doctor_id, start_date.to_s, end_date.to_s, params[:selected_days])
      end
    else
      ApplyForOneDayWorker.new.perform(agency_id, doctor_id, start_date.to_s, end_date.to_s)
    end
    render json: {success: true}
  end

  api :PUT, '/schedules/update_event', 'Get default schedules'
  param_group :event, Api::V1::Docs::CalendarsDoc
  example Api::V1::Docs::CalendarsDoc.update_event_desc
  def update_event
    bool = {"true" => true, "false" => false}
    defaults = {"0" => "default_common_unavailable", "1" => "default_common_available"}
    customs = {"0" => "custom_unavailable", "1" => "custom_available"}
    if current_agency
      agency_id = current_agency.id
      doctor_id = params[:doctor_id]
    else
      doctor_id = current_doctor.id
      agency_id = current_doctor.agency.try(:id)
    end
    starttime_at = params[:agency_period][:start_at].to_datetime.strftime("%H:%M")
    start_at = params[:agency_period][:start_at].to_datetime

    endtime_at = params[:agency_period][:end_at].to_datetime.strftime("%H:%M")
    end_at = params[:agency_period][:end_at].to_datetime

    count_periods = TimeDifference.between(start_at, end_at).in_minutes.to_i/15
    end_at = (count_periods > 1) ? (end_at + 2.minutes) : end_at
    while (start_at < end_at) do
      agency_periods = AgencyPeriod.where("start_at >= (?) and start_at <= (?)", start_at.beginning_of_day, start_at.end_of_day)
      if bool[params[:agency_period][:is_default_week]]
        if params[:agency_period][:doctor_id].present?

          a_period = agency_periods.where(week_day: start_at.wday, starttime_at: start_at.strftime("%H:%M"))
                     .where(agency_id: params[:agency_period][:agency_id],
                            doctor_id: params[:agency_period][:doctor_id]).first
        else
          a_period = AgencyPeriod.where(is_default_week: bool[params[:agency_period][:is_default_week]],
            week_day: start_at.wday, starttime_at: start_at.strftime("%H:%M"))
          .find_by_agency_id(params[:agency_period][:agency_id])
        end
      else
        if params[:agency_period][:doctor_id].present?
          a_period = agency_periods.where(starttime_at: start_at.strftime("%H:%M"))
                     .where(agency_id: params[:agency_period][:agency_id], doctor_id: params[:agency_period][:doctor_id]).first
        else
          a_period = AgencyPeriod.where(is_default_week: bool[params[:agency_period][:is_default_week]], starttime_at: start_at.strftime("%H:%M")).find_by_agency_id(params[:agency_period][:agency_id])
        end
      end
      if a_period.nil?
        a_period = AgencyPeriod.create(
                            week_day: start_at.wday,
                            start_at: start_at,
                            end_at: start_at + 15.minutes,
                            starttime_at: start_at.strftime("%H:%M"),
                            agency_id: params[:agency_period][:agency_id],
                            doctor_id: params[:agency_period][:doctor_id],
                            custom_status: customs[params[:agency_period][:custom_status]],
                            default_common_status: defaults[params[:agency_period][:default_common_status]],
                            is_default_week: params[:agency_period][:is_default_week])
      else
        a_period.update_attributes(default_common_status: defaults[params[:agency_period][:default_common_status]])
        a_period.update_attributes(custom_status: customs[params[:agency_period][:custom_status]])
      end

      start_at = start_at + 15.minutes
      puts "================#{start_at.inspect}"
    end
    render json: {success: true}
  end

end
