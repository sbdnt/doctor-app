require 'sidekiq'
require 'sidekiq/web'

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == ["sidekiq@doctorapp.com", "1234qwer"]
end

def load_sidekiq_config
  if ENV['REDISTOGO_URL']
    return {url: ENV['REDISTOGO_URL'], namespace: 'doctor-app-production'}
  else
    redis_file = File.join(Rails.root, "config", "redis.yml")
    if File.file?(redis_file)
      redis = YAML.load_file(redis_file)[Rails.env].symbolize_keys
      url = 'redis://'+ redis[:host].to_s + ':' + redis[:port].to_s + '/12'
      return { url: url, namespace: redis[:namespace] }
    else
      return { url: 'redis://localhost:6379/12', namespace: 'doctor-app-production' }
    end
  end
end

Sidekiq.configure_server do |config|
  config.redis = load_sidekiq_config

  # Increase the pool
  database_url = ENV['DATABASE_URL']
  if database_url
    ENV['DATABASE_URL'] = "#{database_url}?pool=25"
    ActiveRecord::Base.establish_connection
  end

  # set max failures report saved
  config.failures_max_count = 2000
end

Sidekiq.configure_client do |config|
  config.redis = load_sidekiq_config
end
