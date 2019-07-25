module Api
  module V1
    module Doctors
      class SessionsController < BaseController
        skip_before_filter :api_authenticate_doctor!

        api :POST, '/doctors/sessions', 'Doctor log in'
        param :email, String, desc: "Doctor's email", :required => true
        param :password, String, desc: "Doctor's password", :required => true
        param :device_token, String, desc: "Doctor's device_token"
        param :platform, String, desc: "Doctor's device platform, value = ios/android"
        example Api::V1::Docs::Doctors::SessionsDoc.create
        def create
          if params[:email].blank?
            render json: { success: false, errors: 'Missing email' }, status: 422 and return
          end
          if params[:password].blank?
            render json: { success: false, errors: 'Missing password' }, status: 422 and return 
          end
          doctor = Doctor.where(email: params[:email]).first
          if doctor
            if doctor.valid_password?(params[:password])
              case doctor.status
              when "approved"
                doctor.send(:generate_auth_token)
                doctor.update_columns(auth_token: doctor.auth_token)
                if params[:device_token].present? && params[:platform].present?
                  # Set all doctor's device_token with this params[:device_token] to nil
                  Doctor.where(device_token: params[:device_token]).update_all(device_token: nil)
                  doctor.update_columns(device_token: params[:device_token], platform: params[:platform])
                end
                render json: { success: true, doctor: doctor.as_json }, status: 200
              when "pending"
                render json: { success: false, errors: "Your account is pending, please contact admin for more information" }, status: 422
              when "rejected"
                render json: { success: false, errors: "Your account has been rejected, please contact admin for more information" }, status: 422
              end
            else
              render json: {success: false, errors: "Password was incorrect"}, status: 422
            end
          else
            render json: { success: false, errors: "Email does not exist" }, status: 422
          end
        end
      end
    end
  end
end