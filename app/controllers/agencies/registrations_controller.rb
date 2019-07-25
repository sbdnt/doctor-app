class Agencies::RegistrationsController < Devise::RegistrationsController
  layout "landing_register", :except => :after_landing_sign_up

  def new
    super
    params[:live].present? ? session[:live] = "live" : session[:live] = nil
  end
  # POST /resource
  def create
    build_resource(sign_up_params)

    resource_saved = resource.save
    yield resource if block_given?
    if resource_saved
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_flashing_format?
        # sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
        # redirect_to after_sign_up_path_for(resource)
      else
        # set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
        # flash[:notice] = "Thank you for your interest in GPDQ. A member of our team will be in touch with you shortly."
        expire_data_after_sign_in!
        # respond_with resource, location: after_inactive_sign_up_path_for(resource)
        if session[:live] == "live"
          respond_with resource, location: after_sign_up_success_path
        else
          # respond_with resource, location: home_path
          respond_with resource, location: after_sign_up_path_for(resource)
        end
      end
      if sign_up_params[:role] == "GP"
        doctor = Doctor.new(sign_up_params)
        doctor.save(validate: false)
      end
    else
      clean_up_passwords resource
      @validatable = devise_mapping.validatable?
      if @validatable
        @minimum_password_length = resource_class.password_length.min
      end
      # redirect_to new_agency_session_path
      respond_with resource
    end
  end

  protected
  def after_sign_up_path_for(resource)
    # after_sign_in_path_for(resource)
    #root_path
    new_agency_session_path
  end
  # The path used after sign up. You need to overwrite this method
  # in your own RegistrationsController.
  def after_inactive_sign_up_path_for(resource)
    super
    #new_agency_session_path
    root_path
  end
  def sign_up_params
    # devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:email, :password, :password_confirmation, :name, :address, :phone_number) }
    params.require(:agency).permit(:email, :password, :password_confirmation, :name, :address, :phone_number, :account_number, :bank_name, :branch_address, :sort_code, :first_name, :last_name, :gender, :role, :company_name, :answer_about_us)
  end
  def account_update_params
    # devise_parameter_sanitizer.sanitize(:account_update)
    params.require(:agency).permit(:email, :name, :address, :phone_number, :account_number, :bank_name, :branch_address, :sort_code, :first_name, :last_name, :gender, :role, :company_name, :answer_about_us)
  end
  def update_resource(resource, params)
    #resource.update_attributes(params)
    resource.update_without_password(params.except(:current_password))
  end
  def after_update_path_for(resource)
    root_path
  end
end
