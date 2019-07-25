class Doctors::CalendarsController < ApplicationController
  
  def show
    if request.xhr?
      agency_id = current_doctor.agency_id
      start_date = params[:start_time].to_datetime
      end_date = params[:end_time].to_datetime
      if TimeDifference.between(start_date, end_date).in_days.to_i <=1
        for_week = false
      else
        for_week = true
      end
      res = []
      while(start_date < end_date) do
        apply = ApplySchedule.where(:on_date => start_date.beginning_of_day..start_date.end_of_day).where(doctor_id: params[:id], agency_id: agency_id).first
        options = {for_week: for_week, start_date: start_date.to_s, agency_id: agency_id, doctor_id: params[:id], changed_by: "custom_status"}
        res << Period.order("start_at").map{|p| p.as_json_doctor_custom(options).merge({doctor_id: params[:id], changed_by: "custom_status"})}  #if (apply.present? && apply.is_apply) || agency_id.blank?
        start_date += 1.day
      end
      render json: {events: res.uniq.flatten, is_apply_week: apply.try(:is_apply_week), is_apply: apply.try(:is_apply)}
    end
  end

  def edit_event
    if params[:agency_period_id].blank?
      @period = AgencyPeriod.new(period_id: params[:period_id])
    else
      @period = AgencyPeriod.find_by_id(params[:agency_period_id])
    end

    @start_at = params[:start_at]
    @doctor_id = params[:doctor_id]
    @changed_by = params[:changed_by]
    @period_id = params[:period_id]
    if agency_signed_in?
      @agency_id = current_agency.try(:id)
    else
      @agency_id = current_doctor.agency_id
    end
  end

  def update_event
    if params[:agency_period][:doctor_id].present?
      a_period = AgencyPeriod.where("start_at >= (?) and start_at <= (?)", params[:agency_period][:start_at].to_datetime, start_at.to_datetime + 15.minutes)
                 .where(agency_id: params[:agency_period][:agency_id], period_id: params[:agency_period][:period_id], doctor_id: params[:agency_period][:doctor_id]).first
    else
      a_period = AgencyPeriod.where("start_at >= (?) and start_at <= (?)", params[:agency_period][:start_at].to_datetime, params[:agency_period][:start_at].to_datetime + 15.minutes).find_by_agency_id_and_period_id(params[:agency_period][:agency_id], params[:agency_period][:period_id])
    end
    if a_period.nil?
      AgencyPeriod.create(agency_period_params)
    else
      if params[:agency_period][:default_specific_status].present?
        a_period.update_attributes(default_specific_status: params[:agency_period][:default_specific_status])
      elsif params[:agency_period][:default_common_status].present?
        a_period.update_attributes(default_common_status: params[:agency_period][:default_common_status])
      elsif params[:agency_period][:custom_status].present?
        a_period.update_attributes(custom_status: params[:agency_period][:custom_status])
      end
    end
  end
  def apply_default_schedule
    date = params[:week_day].to_datetime.utc
    apply_schedule = ApplySchedule.where(:on_date => date.beginning_of_day..date.end_of_day).where(doctor_id: params[:doctor_id], agency_id: params[:agency_id]).first
    if params[:is_apply].to_i == 1
      agency_periods = ApplySchedule.where(:on_date => date.beginning_of_day..date.end_of_day).where(doctor_id: params[:doctor_id], agency_id: params[:agency_id])
      agency_periods.each do |ap|
        if ap.default_common_available?
          ap.default_specific_status = "default_specific_available" if ap.default_specific_status.nil?
          ap.custom_status = "common_available" if ap.custom_status.nil?
        elsif ap.default_common_unavailable?
          ap.default_specific_status = "default_specific_unavailable" if ap.default_specific_status.nil?
          ap.custom_status = "common_unavailable" if ap.custom_status.nil?
        end
      end
    end
    if apply_schedule.nil?
      ApplySchedule.create(is_apply_day: params[:is_apply_day], is_apply: params[:is_apply], on_date: date, doctor_id: params[:doctor_id], agency_id: params[:agency_id])
    else
      apply_schedule.update_attributes(is_apply: params[:is_apply])
    end
    render json: {}
  end

  private

  def agency_period_params
    # NOTE: Using `strong_parameters` gem
    params.required(:agency_period).permit(:agency_id, :is_default_week, :week_day, :is_apply_default_to_custom, :starttime_at, :endtime_at, :default_common_status, :default_specific_status, :custom_status, :start_at, :end_at, :period_id, :doctor_id, :changed_by)
  end

end
