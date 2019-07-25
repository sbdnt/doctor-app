module Api
  module V1
    module Doctors
      class BaseController < ActionController::Base
        resource_description do
          app_info "APIs for Doctor"
          api_versions "doctors"
        end

        before_filter :api_authenticate_doctor!

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

        rescue_from Exceptions::ApiParameterMissing do |exception|
          error = exception.to_json
          error['success'] = false
          render :status => 422, :json => error
        end

        def api_authenticate_doctor!
          @current_doctor = Doctor.find_by_auth_token(params[:auth_token]) if params[:auth_token]
          if @current_doctor.nil?
            render :json => { :errors => t('controller.common.unauthorized')},
                   :status => 401
          end
        end

        def current_doctor
          @current_doctor ||= Doctor.find_by_auth_token(params[:auth_token])
        end
      end
    end
  end
end