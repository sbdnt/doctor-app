class Api::V1::Patients::SessionsController < Api::V1::BaseApiController
  skip_before_filter :api_authenticate_patient!

  api :POST, '/patients/sessions', 'Login patient normal'
  param_group :login_normal, Api::V1::Docs::Patients::SessionsDoc
  example Api::V1::Docs::Patients::SessionsDoc.create
  def create
    required :email if params[:patient].present? && params[:patient][:email].blank? || params[:patient].nil?
    required :password if params[:patient].present? && params[:patient][:password].blank? || params[:patient].nil?
    resource = Patient.find_for_database_authentication(:email=> params[:patient][:email])
    
    # return invalid_login_attempt unless resource
    if resource.nil?
      render status: 401, json: {success: false, errors: "Email does not exist"}
    else
      if resource.valid_password?(params[:patient][:password])
        if params[:patient][:device_token].present? && params[:patient][:platform].present?
          # Set all patient's device_token with this params[:device_token] to nil
          Patient.where(device_token: params[:patient][:device_token]).update_all(device_token: nil)
          resource.device_token = params[:patient][:device_token]
          resource.platform = params[:patient][:platform]
        end
        resource.save(validate: false)
        resource.send(:generate_auth_token)
        resource.update_columns(auth_token: resource.auth_token)
        if params[:patient] && params[:patient][:lat].present? && params[:patient][:lng].present?
          GeoPatient.find(resource.id).save_location(params[:patient][:lat], params[:patient][:lng])
        end
        if params[:patient].present? && params[:patient][:address].present?
          location = Location.find_by_address(params[:address])
          location.update_attributes(patient_id: resource.id, is_current: true) if location
          resource.update_attributes(:address => location.address)
        end
        render status: 200, json: {patient_info: resource.as_json_common, success: true}
      else
        render status: 401, json: {success: false, errors: "Password was incorrect"}
      end
    end
  end

  api :POST, '/patients/sessions/login_with_fb', 'Login patient with fb'
  param_group :login_fb, Api::V1::Docs::Patients::SessionsDoc
  example Api::V1::Docs::Patients::SessionsDoc.login_with_fb_desc
  def login_with_fb
    required :fb_id, :fb_token
    if params[:fb_id].blank?
      render json: { message: "Missing Facebook id", errors: "fb_id can't be blank" }, status: 400
    else
      patient = Patient.find_by_fb_id(params[:fb_id])
      if patient.present?
        begin
          fb_user = FbGraph::User.me(params[:fb_token]).fetch
          if params[:device_token].present? && params[:platform].present?
            # Set all patient's device_token with this params[:device_token] to nil
            Patient.where(device_token: params[:device_token]).update_all(device_token: nil)
            patient.device_token = params[:device_token]
            patient.platform = params[:platform]
          end
          patient.save(validate: false)
          if params[:lat].present? && params[:lng].present?
            GeoPatient.find(patient.id).save_location(params[:lat], params[:lng])
          end
          render status: 200, json: patient.as_json
        rescue
          render :json => {message: t("controller.sessions.invalid_fb_token")}, status: 400
          return
        end
      else
        render json: { message: "You don't have an existing account, please access to the register section" }, status: 422
      end
    end
  end

end
