class Agencies::SessionsController < Devise::SessionsController
  # GET /resource/sign_in
  def new
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    sign_out(:doctor)
    respond_with(resource, serialize_options(resource))
  end
end
