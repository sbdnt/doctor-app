module Api
  module V1
    module Doctors
      class PasswordsController < BaseController
        skip_before_filter :api_authenticate_doctor!, only: [:forgot]

        api :PUT, '/doctors/passwords/forgot', 'Forgot passwords'
        param :email, String, desc: "Doctor's Email", :required => true
        example Api::V1::Docs::Doctors::PasswordsDoc.forgot
        def forgot
          if params[:email].blank?
            render json: { success: false, errors: "Missing email" }, status: 422 and return
          end
          doctor = Doctor.find_by_email(params[:email])
          if doctor.present?
            new_password = SecureRandom.hex(6)
            if doctor.update(password: new_password, password_confirmation: new_password)
              DoctorMailer.forgot_password(doctor.id, new_password).deliver
              render json: { success: true }, status: 200
            else
              render json: {errors: doctor.errors.full_messages.first, success: false}, status: 422
            end
          else
            render json: { success: false, errors: "Email doesn't exist" }, status: 422
          end
        end
      end
    end
  end
end