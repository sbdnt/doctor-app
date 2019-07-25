class Patients::PasswordsController < Devise::PasswordsController
  layout :compute_layout

  # GET /resource/password/new
  def new
    self.resource = resource_class.new
    @email = params[:email].present? ? params[:email] : ""
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  def edit
    self.resource = resource_class.new
    resource.reset_password_token = params[:reset_password_token]
  end

  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    puts "error = #{resource.errors.inspect}"
    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      # flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      # set_flash_message(:notice, flash_message) if is_flashing_format?
      # sign_in(resource_name, resource)
      # respond_with resource, location: after_resetting_password_path_for(resource)
      # respond_with resource, location: patients_maps_path(:tab => "yes")
      unless resource.active_for_authentication?
        flash_message = :updated_not_active
        set_flash_message(:notice, flash_message) if is_flashing_format?
      else
        flash[:success] = "Your password has been changed successfully."
      end
      respond_with resource, location: root_path
    else
      respond_with resource
    end
  end

  def compute_layout
    action_name == "new" ? "patient" : false
  end
end
