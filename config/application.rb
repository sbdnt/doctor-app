require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
module DoctorApp
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths += %W(#{config.root}/lib)
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'London'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address:              'smtp.mandrillapp.com',
      port:                 587,
      domain:               'doctor-app.herokuapp.com',
      user_name:            'quangquach',
      password:             "YJXEHBM5FAfYiTvLRvV_IQ",#MANDRILL_CONFIG[:api_key],
      authentication:       'plain',
      enable_starttls_auto: true  }
  end
end

PAYPAL_MODE = "sandbox"
PAYPAL_REDIRECT_URL = "http://doctor-app.herokuapp.com/"
PAYPAL_CLIENT_ID = "AWCnKlFd7b3T9PTwbPL7s3SLr7OeJ8u6JXKfa2LIlz5pa_K8OOv3lVupcTMi_JHnrmCzKWrvWss0Lmtu"
PAYPAL_SECRET = "EAkgoNTwjaQeS5ZMk_rMsccT-W427m9XXxvgZT83kJdycsXBRJYcrUbG6pkTa_nA4T0EgZG5xuilEM_W"