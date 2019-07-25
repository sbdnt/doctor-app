class Patients::RegistrationsController < Devise::RegistrationsController
# before_filter :configure_sign_up_params, only: [:create]
# before_filter :configure_account_update_params, only: [:update]
  layout "patient"

  # GET /resource/sign_up
  def new
    @tc = TermsCondition.first
    if params[:referral_code].present?
      @referred_by = ReferralCode.find_by_voucher_code(params[:referral_code]).try(:sponsor_id)
    end
    build_resource({})
    @validatable = devise_mapping.validatable?
    if @validatable
      @minimum_password_length = resource_class.password_length.min
    end
    respond_with self.resource
  end

  # POST /resource
  def create
    @tc = TermsCondition.first
    build_resource(sign_up_params)

    resource_saved = resource.save
    yield resource if block_given?
    if resource_saved
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
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
  def edit
    @tc = TermsCondition.first
    render :edit
  end

  # PUT /resource
  def update
    @tc = TermsCondition.first
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?
    if resource_updated
      if is_flashing_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      sign_in resource_name, resource, bypass: true
      respond_with resource, location: patient_view_profile_path
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

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

  # protected

  # def sign_in_params
  #   devise_parameter_sanitizer.sanitize(:sign_in)
  # end

  # You can put the params you want to permit in the empty array.
  def sign_up_params
    # devise_parameter_sanitizer.for(:sign_up) << :attribute
    params.require(:patient).permit(:email, :password, :password_confirmation, :first_name, :last_name, :fullname,
                                    :avatar, :avatar_cache, :address, :zone_id, :phone_number, :account_number,
                                    :bank_name, :branch_address, :sort_code, :terms_of_service, :over_18, :referred_by)
  end

  # You can put the params you want to permit in the empty array.
  def account_update_params
    params.require(:patient).permit(:email, :first_name, :last_name, :fullname,
                                    :avatar, :avatar_cache, :address, :zone_id, :phone_number, :account_number,
                                    :bank_name, :branch_address, :sort_code)
  end

  def update_resource(resource, params)
    #resource.update_attributes(params)
    resource.update_without_password(params.except(:current_password))
  end

  # def after_update_path_for(resource)
  #   root_path
  # end

  # def configure_account_update_params
  #   devise_parameter_sanitizer.for(:account_update) << :attribute
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super
  #   new_doctor_session_path
  # end
end
