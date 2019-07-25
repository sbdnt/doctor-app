class Patients::SessionsController < Devise::SessionsController
# before_filter :configure_sign_in_params, only: [:create]
  layout false

  # GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_flashing_format?
    sign_in(resource_name, resource)
    yield resource if block_given?
    if session[:not_logged_address].nil?
      respond_with resource, location: patients_maps_path(:tab => "yes")
    else
      unless session[:not_logged_location_id].nil?
        location = Location.find_by_id(session[:not_logged_location_id].to_i)
        location.update_attributes(patient_id: current_patient.id, is_current: true)
        current_patient.update_attributes(:address => location.address)
      end
      session.delete :not_logged_address
      session.delete :not_logged_address
      session.delete :not_logged_location_id
      respond_with resource, location: patients_payments_path(:tab => "yes", :confirm => true, payment_tab: 'credit')
    end
  end
end
