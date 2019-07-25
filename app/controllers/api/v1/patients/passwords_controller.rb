class Api::V1::Patients::PasswordsController < Api::V1::BaseApiController
  skip_before_filter :api_authenticate_patient!, only: [:forgot]

  api :PUT, '/patients/passwords/forgot', 'Forgot passwords'
  param_group :forgot_params, Api::V1::Docs::Patients::PasswordsDoc
  example Api::V1::Docs::Patients::PasswordsDoc.forgot_desc
  def forgot
    required :email
    patient = Patient.find_by_email(params[:email])
    # new_password = SecureRandom.hex(6)
    if patient.present?
      # if patient.update_attributes(password: new_password, password_confirmation: new_password)
      #   PatientMailer.forgot_password(patient.id, new_password).deliver
      #   render json: {success: true}
      # else
      #   render json: {errors: patient.errors.full_messages.first, success: false}, status: 422
      # patient.send_reset_password_instructions
      SendResetEmailWorker.perform_async(patient.id, "Patient")
      render json: {success: true}
    else
      render json: {errors: "Email doesn't exist", success: false}, status: 422
    end
  end

  # Updated: Thanh
  api :PUT, '/patients/passwords/new_password', "Change patient's password"
  param_group :new_password, Api::V1::Docs::Patients::PasswordsDoc
  example Api::V1::Docs::Patients::PasswordsDoc.new_password
  def new_password
    required :current_password
    required :new_password
    if current_patient.valid_password?(params[:current_password])
      if current_patient.update_attributes(password: params[:new_password], password_confirmation: params[:new_password])
        render json: {success: true}
      else
        render json: {errors: current_patient.errors.full_messages.first, success: false}, status: 400
      end
    else
      render json: {errors: "Current password is wrong", success: false}, status: 422
    end
  end

end
