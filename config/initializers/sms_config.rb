# Load text marketer to config send sms for environment
TEXT_SMS = YAML.load_file("#{Rails.root.to_s}/config/textmarketer.yml")[Rails.env].symbolize_keys
