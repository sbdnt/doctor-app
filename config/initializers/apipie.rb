Apipie.configure do |config|
  config.app_name                = "DoctorApp"
  config.api_base_url            = "/api/v1"
  config.doc_base_url            = "/apidoc"
  config.validate                = false

  config.api_controllers_matcher = ["#{Rails.root}/app/controllers/api/v1/*.rb", "#{Rails.root}/app/controllers/api/v1/patients/*.rb", "#{Rails.root}/app/controllers/api/v1/doctors/*.rb"]
  # config.authenticate = Proc.new do
  #    authenticate_or_request_with_http_basic do |username, password|
  #      username == "dev@doctorapp.com" && password == "1234qwer"
  #   end
  # end
end