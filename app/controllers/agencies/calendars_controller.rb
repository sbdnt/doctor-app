class Agencies::CalendarsController < ApplicationController
  #before_filter :authenticate_agency!
  def index
    if request.xhr?
      start_date = params[:start_time].to_datetime
      end_date = params[:end_time].to_datetime
      res = []
      if TimeDifference.between(start_date, end_date).in_days.to_i <=1
        for_week = false
      else
        for_week = true
      end

      while(start_date < end_date) do
        res << Period.order("start_at").map{|p| p.as_json({wday: start_date.wday, start_date: start_date.to_s, agency_id: current_agency.id, for_week: for_week, changed_by: "default_common_status"})}
        start_date += 1.day
      end
      render json: res.uniq.flatten
    end
  end

  def doctor_list
    params[:sort] ||= 'name'
    params[:sort_direction] ||= 'asc'
    doctor_list = Doctor.where(agency_id: current_agency.id)
    if params[:query].present?
      doctor_list = doctor_list.where('name ilike ?',  "#{params[:query]}%")
    end
    @doctor_list = doctor_list.order( params[:sort] + ' ' + params[:sort_direction] )

    params[:sort_direction] = params[:sort_direction] == 'asc' ? 'desc' : 'asc'
  end

  def custom_schedules_of_doctor
    if request.xhr?
      if agency_signed_in?
        agency_id = current_agency.try(:id)
        doctor_id = params[:doctor_id]
      else
        agency_id = current_doctor.agency_id
        doctor_id = current_doctor.id#params[:id]
      end
      session[:doctor_id] = doctor_id
      start_date = params[:start_time].nil? ? Date.today : params[:start_time].to_datetime
      end_date = params[:end_time].nil? ? Date.today : params[:end_time].to_datetime
      res = []
      apply = nil
      if TimeDifference.between(start_date, end_date).in_days.to_i <=1
        for_week = false
      else
        for_week = true
      end
      while(start_date < end_date) do
        options = {wday: start_date.wday, start_date: start_date.to_s, agency_id: agency_id, doctor_id: doctor_id, changed_by: "custom_status", for_week: for_week}
        res << Period.order("start_at").map{|p| p.as_json_doctor_custom(options).merge({doctor_id: doctor_id, changed_by: "custom_status"})}
        start_date += 1.day
      end
      render json: {events: res.uniq.flatten}
    end
  end

  def edit_default_schedule
    if params[:agency_period_id].blank?
      @period = AgencyPeriod.new(period_id: params[:period_id], start_at: params[:start_at].to_datetime, end_at: params[:start_at].to_datetime + 15.minutes)
    else
      @period = AgencyPeriod.find_by_id(params[:agency_period_id])
    end

    @start_at = params[:start_at]
    @doctor_id = params[:doctor_id]
    @changed_by = params[:changed_by]
    @period_id = params[:period_id]
    @appointment_id = params[:appointment_id]
    if params[:changed_by] == "custom_status"
      @default_week = nil
    else
      @default_week = params[:default_week]
    end
    if agency_signed_in?
      @agency_id = current_agency.try(:id)
    else
      @agency_id = current_doctor.agency_id
    end
  end

  def detail_appointment
    @appointment = Appointment.find_by_id(params[:appointment_id])
  end

  def update_default_schedule
    bool = {"true" => true, "false" => false}
    if agency_signed_in?
      @doctor_id = params[:doctor_id]
    else
      @doctor_id = params[:id]
    end
    
    starttime_at = "#{params[:agency_period]['start_at(4i)']}:#{params[:agency_period]['start_at(5i)']}"
    start_at = ("#{params[:agency_period]['start_at(1i)']}-#{params[:agency_period]['start_at(2i)']}-#{params[:agency_period]['start_at(3i)']}" + " #{starttime_at}").to_datetime

    endtime_at = "#{params[:agency_period]['end_at(4i)']}:#{params[:agency_period]['end_at(5i)']}"
    end_at = ("#{params[:agency_period]['end_at(1i)']}-#{params[:agency_period]['end_at(2i)']}-#{params[:agency_period]['end_at(3i)']}" + " #{endtime_at}").to_datetime
    
    count_periods = TimeDifference.between(start_at, end_at).in_minutes.to_i/15
    end_at = (count_periods > 1) ? (end_at + 2.minutes) : end_at
    while (start_at < end_at) do
      agency_periods = AgencyPeriod.where("start_at >= (?) and start_at <= (?)", start_at.beginning_of_day, start_at.end_of_day)
      if bool[params[:agency_period][:is_default_week]]
        if params[:agency_period][:doctor_id].present?

          a_period = agency_periods.where(week_day: start_at.wday, starttime_at: start_at.strftime("%H:%M"))
                     .where(agency_id: params[:agency_period][:agency_id], doctor_id: params[:agency_period][:doctor_id]).first
        else
          a_period = AgencyPeriod.where(is_default_week: bool[params[:agency_period][:is_default_week]], week_day: start_at.wday, starttime_at: start_at.strftime("%H:%M")).find_by_agency_id(params[:agency_period][:agency_id])
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
        AgencyPeriod.create(
                            week_day: start_at.wday, 
                            start_at: start_at, 
                            end_at: start_at + 15.minutes,
                            starttime_at: start_at.strftime("%H:%M"),
                            agency_id: params[:agency_period][:agency_id], 
                            doctor_id: params[:agency_period][:doctor_id], 
                            custom_status: params[:agency_period][:custom_status],
                            default_common_status: params[:agency_period][:default_common_status],
                            is_default_week: params[:agency_period][:is_default_week])
      else
        a_period.update_attributes(default_common_status: params[:agency_period][:default_common_status])
        a_period.update_attributes(custom_status: params[:agency_period][:custom_status])
      end
      
      start_at = start_at + 15.minutes
      #starttime_at = start_at.strftime("%H:%M")
    end
  end

  def apply_default_schedule
    start_date = params[:start_time].blank? ? Date.today : params[:start_time].to_datetime
    end_date = params[:end_time].blank? ? start_date : params[:end_time].to_datetime
    res = []
    if TimeDifference.between(start_date, end_date).in_days.to_i <=1
      for_week = false
    else
      for_week = true
    end
    doctor_id = params[:doctor_id].blank? ? session[:doctor_id] : params[:doctor_id]
    if for_week
      if params[:is_default_week] == true || params[:is_default_week] == "true"
        ApplyDefaultWeekWorker.new.perform(params[:agency_id], doctor_id, start_date.to_s, end_date.to_s, params[:selected_days])
      else
        puts "how #{for_week}"
        ApplyDefaultDayWorker.new.perform(params[:agency_id], doctor_id, start_date.to_s, end_date.to_s, params[:selected_days])
      end
    else
      ApplyForOneDayWorker.new.perform(params[:agency_id], doctor_id, start_date.to_s, end_date.to_s)
    end
  end
  
  def show
  end

  private

  def agency_period_params
    # NOTE: Using `strong_parameters` gem
    params.required(:agency_period).permit(:agency_id, :is_default_week, :week_day, :is_apply_default_to_custom, :starttime_at, :endtime_at, :default_common_status, :default_specific_status, :custom_status, :start_at, :end_at, :period_id, :doctor_id, :changed_by)
  end
end
