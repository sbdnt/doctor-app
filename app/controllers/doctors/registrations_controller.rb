class Doctors::RegistrationsController < Devise::RegistrationsController
# before_filter :configure_sign_up_params, only: [:create]
# before_filter :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    build_resource({})
    @validatable = devise_mapping.validatable?
    @zones = Zone.order('name')
    if @validatable
      @minimum_password_length = resource_class.password_length.min
    end
    respond_with self.resource
  end

  # POST /resource
  def create
    build_resource(sign_up_params)
    @zones = Zone.order('name')
    resource_saved = resource.save
    yield resource if block_given?
    if resource_saved
      if current_agency.nil?
        if resource.active_for_authentication?
          set_flash_message :notice, :signed_up if is_flashing_format?
          sign_up(resource_name, resource)
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          # set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
          flash[:notice] = "Doctor has been created successfully."
          expire_data_after_sign_in!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        flash[:notice] = "Doctor has been created successfully."
        redirect_to doctors_path
      end
    else
      clean_up_passwords resource
      @validatable = devise_mapping.validatable?
      if @validatable
        @minimum_password_length = resource_class.password_length.min
      end
      respond_with resource
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  def sign_in_params
    devise_parameter_sanitizer.sanitize(:sign_in)
  end

  # You can put the params you want to permit in the empty array.
  def sign_up_params
    # devise_parameter_sanitizer.for(:sign_up) << :attribute
    params.require(:doctor).permit(:email, :password, :password_confirmation, :name, :description, :first_name, :last_name, :role, :agency_id,
                                   :phone_number, :phone_landline, :avatar, :avatar_cache,
                                   :gmc_cert, :gmc_cert_exp, :gmc_cert_cache, :dbs_cert,
                                   :dbs_cert_exp,:dbs_cert_cache, :mdu_mps_cert, :mdu_mps_cert_exp,
                                   :mdu_mps_cert_cache, :passport, :passport_cache, :default_start_location,
                                   :last_appraisal_summary, :last_appraisal_summary_exp,
                                   :last_appraisal_summary_cache, :reference_gp,
                                   :reference_gp_cache, :hepatitis_b_status,
                                   :hepatitis_b_status_exp, :hepatitis_b_status_cache,
                                   :child_protection_cert, :child_protection_cert_exp,
                                   :child_protection_cert_cache, :adult_safeguarding_cert,
                                   :adult_safeguarding_cert_exp, :adult_safeguarding_cert_cache,
                                   doctor_zones_attributes: [:zone_id, :doctor_id, :eta, :_destroy, :id])
  end

  # You can put the params you want to permit in the empty array.
  def account_update_params
    params.require(:doctor).permit(:email, :name, :first_name, :last_name, :role, :phone_number, :description, :phone_landline, :agency_id,
                                   :avatar, :avatar_cache, :gmc_cert, :gmc_cert_exp,
                                   :gmc_cert_cache, :dbs_cert, :dbs_cert_exp,:dbs_cert_cache,
                                   :mdu_mps_cert, :mdu_mps_cert_exp, :mdu_mps_cert_cache,
                                   :passport, :passport_cache, :default_start_location,
                                   :last_appraisal_summary, :last_appraisal_summary_exp,
                                   :last_appraisal_summary_cache, :reference_gp, :available,
                                   :reference_gp_cache, :hepatitis_b_status,
                                   :hepatitis_b_status_exp, :hepatitis_b_status_cache,
                                   :child_protection_cert, :child_protection_cert_exp,
                                   :child_protection_cert_cache, :adult_safeguarding_cert,
                                   :adult_safeguarding_cert_exp, :adult_safeguarding_cert_cache,
                                   doctor_zones_attributes: [:zone_id, :doctor_id, :eta, :_destroy, :id])
  end

  def update_resource(resource, params)
    #resource.update_attributes(params)
    resource.update_without_password(params.except(:current_password))
  end

  def after_update_path_for(resource)
    root_path
  end

  # def configure_account_update_params
  #   devise_parameter_sanitizer.for(:account_update) << :attribute
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  def after_inactive_sign_up_path_for(resource)
    super
    new_doctor_session_path
  end
end
