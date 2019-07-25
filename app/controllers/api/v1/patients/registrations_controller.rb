class Api::V1::Patients::RegistrationsController < Api::V1::BaseApiController
  skip_before_filter :api_authenticate_patient!

  api :POST, '/patients/registrations/sign_up_with_fb', 'Sign Up with FB'
  param_group :signup_fb, Api::V1::Docs::Patients::RegistrationsDoc
  example Api::V1::Docs::Patients::RegistrationsDoc.sign_up_with_fb_desc
  def sign_up_with_fb
    #required :fb_id, :email, :phone_number, :terms_of_service, :over_18 unless params[:patient].present?
    required_raise_one :fb_id if params[:patient].present? && params[:patient][:fb_id].blank? || params[:patient].nil?
    required_raise_one :fullname if params[:patient].present? && params[:patient][:fullname].blank? || params[:patient].nil?
    required_raise_one :email if params[:patient].present? && params[:patient][:email].blank? || params[:patient].nil?
    required_raise_one :password if params[:patient].present? && params[:patient][:password].blank? || params[:patient].nil?
    required_raise_one :phone_number if params[:patient].present? && params[:patient][:phone_number].blank? || params[:patient].nil?
    required_raise_one :terms_of_service if params[:patient].present? && params[:patient][:terms_of_service].blank? || params[:patient].nil?
    required_raise_one :over_18 if params[:patient].present? && params[:patient][:over_18].blank? || params[:patient].nil?

    # patient = Patient.where(email: sign_up_params[:email], fb_id: sign_up_params[:fb_id], phone_number: sign_up_params[:phone_number]).first
    patient = Patient.where(fb_id: sign_up_params[:fb_id]).first
    if patient.present?
      # Merge the info register on App into the registered account with same fb_id
      # patient.save(validate: false)
      # if patient.update(email: sign_up_params[:email], fullname: sign_up_params[:fullname], phone_number: sign_up_params[:phone_number])
      #   if params[:patient] && params[:patient][:lat].present? && params[:patient][:lng].present?
      #     GeoPatient.find(patient.id).save_location(params[:patient][:lat], params[:patient][:lng])
      #   end
      #   patient.update(device_token: sign_up_params[:device_token], platform: sign_up_params[:platform]) if sign_up_params[:device_token].present? && sign_up_params[:platform].present?
      #   render status: 200, json: patient.as_json

      # else
      render status: 422, json: {errors: "It looks like #{params[:patient][:email]} belongs to an existing account. Please sign in with Facebook"}
    else
      patient = Patient.where(email: sign_up_params[:email]).first

      if patient.present?
        # Merge the register info on App into the registered account with same email
        if patient.update(fb_id: sign_up_params[:fb_id], fullname: sign_up_params[:fullname], phone_number: sign_up_params[:phone_number])
          if params[:patient] && params[:patient][:lat].present? && params[:patient][:lng].present?
            GeoPatient.find(patient.id).save_location(params[:patient][:lat], params[:patient][:lng])
          end
          render status: 200, json: patient.as_json

        else
          render status: 422, json: {errors: patient.errors.full_messages.first,
                                      message: t("controller.registrations.unsuccessfully")}
        end
      else
        # Create new account with the register info from App
        patient = Patient.new sign_up_params
        if patient.save
          if params[:patient] && params[:patient][:lat].present? && params[:patient][:lng].present?
            GeoPatient.find(patient.id).save_location(params[:patient][:lat], params[:patient][:lng])
          end
          render status: 200, json: patient.as_json

        else
          render status: 422, json: { errors: patient.errors.full_messages.first,
                                      message: t("controller.registrations.unsuccessfully")}
        end
      end
    end
  end

  api :POST, '/patients/registrations/sign_up', 'Sign up patient normal'
  param_group :sign_up, Api::V1::Docs::Patients::RegistrationsDoc
  # api_versions "1"
  example Api::V1::Docs::Patients::RegistrationsDoc.sign_up
  def sign_up
    required_raise_one :fullname if params[:patient].present? && params[:patient][:fullname].blank? || params[:patient].nil?
    required_raise_one :email if params[:patient].present? && params[:patient][:email].blank? || params[:patient].nil?
    required_raise_one :phone_number if params[:patient].present? && params[:patient][:phone_number].blank? || params[:patient].nil?
    required_raise_one :password if params[:patient].present? && params[:patient][:password].blank? || params[:patient].nil?
    required_raise_one :terms_of_service if params[:patient].present? && params[:patient][:terms_of_service].blank? || params[:patient].nil?
    required_raise_one :over_18 if params[:patient].present? && params[:patient][:over_18].blank? || params[:patient].nil?
    patient = Patient.new({ fullname: params[:patient][:fullname], email: params[:patient][:email],
                            phone_number: params[:patient][:phone_number],
                            password: params[:patient][:password]
                          })
    patient.device_token = sign_up_params[:device_token] if sign_up_params[:device_token].present?
    patient.platform = sign_up_params[:platform] if sign_up_params[:platform].present?
    if patient.save
      render status: 201, json: {patient_info: patient.as_json_common, success: true}
    else
      render status: 400, json: {success: false, errors: patient.errors.full_messages.first}
    end
  end

  def sign_up_params
    # devise_parameter_sanitizer.for(:sign_up) << :attribute
    params.require(:patient).permit(:email, :password, :password_confirmation,
                                    :phone_number, :fb_id, :fb_token, :fullname,
                                    :terms_of_service, :over_18, :device_token, :platform)
  end
end
