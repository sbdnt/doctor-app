class Api::V1::BaseApiController < ActionController::Base
  before_filter :api_authenticate_patient!

  def current_patient
    if params[:auth_token].blank?
      @current_patient = nil
    else
      @current_patient ||= Patient.find_by_auth_token(params[:auth_token])
    end
  end

  def api_authenticate_patient!
    if params[:auth_token].blank?
      @current_patient = nil
    else
      @current_patient = Patient.find_by_auth_token(params[:auth_token])
    end
    if @current_patient.nil?
      render :json => { :message => t('controller.common.unauthorized')},
             :status => 401
    end
  end

  def current_doctor
    @current_doctor ||= Doctor.find_by_auth_token(params[:auth_token])
  end

  def api_authenticate_doctor!
    @current_doctor = Doctor.find_by_auth_token(params[:auth_token])
    if @current_doctor.nil?
      render :json => { :message => t('controller.common.unauthorized')},
             :status => 401
    end
  end

  def current_agency
    @current_agency ||= Agency.find_by_auth_token(params[:auth_token])
  end

  def api_authenticate_agency!
    @current_agency = Agency.find_by_auth_token(params[:auth_token])
    if @current_agency.nil?
      render :json => { :message => t('controller.common.unauthorized')},
             :status => 401
    end
  end

  def required(*parameters)
    errors = []
    message = ''
    parameters.each do |param|
      if param.class == Hash
        message = param[:message] unless param[:message].blank?
        next
      end
      p params[param.to_sym]
      if params[param.to_sym].blank? && params[param.to_s].blank?
        errors << param
      end
    end
    if errors.size > 0
      raise Exceptions::ApiParameterMissing.new(errors, message)
    end
  end

  def required_raise_one(*parameters)
    errors = []
    message = ''
    parameters.each do |param|
      if param.class == Hash
        message = param[:message] unless param[:message].blank?
        next
      end
      if params[param.to_sym].blank? && params[param.to_s].blank?
        errors << param
        break
      end
    end
    if errors.size > 0
      raise Exceptions::ApiParameterMissing.new(errors, message)
    end
  end

  rescue_from Exceptions::ApiParameterMissing do |exception|
    render :status => 422, :json => exception.to_json
  end

  rescue_from ActiveRecord::RecordNotFound, :with => :render_error_not_found
  def render_error_not_found(exception)
    render_error_basic(exception, t("controller.common.not_found"), 404)
  end
end
