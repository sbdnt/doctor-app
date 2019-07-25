CarrierWave.configure do |config|
  s3_file = File.join(Rails.root, "config", "s3.yml")
  if File.file?(s3_file)
    s3_config = YAML.load_file(s3_file)[Rails.env].symbolize_keys
  else
    s3_config = {
      :provider => ENV['provider'],
      :access_key => ENV['access_key'],
      :secret_access_key => ENV['secret_access_key'],
      :directory => ENV['directory']}
  end
  # config.storage = :fog
  config.fog_credentials = {
    :provider               => s3_config[:provider],
    :aws_access_key_id      => s3_config[:access_key],
    :aws_secret_access_key  => s3_config[:secret_access_key],
    :region                 => s3_config[:region],
  }
  config.fog_public     = false
  config.fog_directory  = s3_config[:directory]
  config.fog_attributes = {'Cache-Control' => 'max-age=315576000'}
end