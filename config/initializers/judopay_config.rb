# Judopay.configure do |config|
#   config.judo_id = "100039-783"
#   config.api_token = 'ZLzu2TffbA45wrHa'
#   config.api_secret = 'e49bfedb324637c920a628ebf3461891e8790977b9bf590522cdbfb67d13fd55'
#   use_production = false
# end

judo_file = File.join(Rails.root, "config", "judopay.yml")
if File.file?(judo_file)
  judo_info = YAML.load_file(judo_file)[Rails.env].symbolize_keys
else
  judo_info = {host: 'partnerapi.judopay-sandbox.com', api_token: "ZLzu2TffbA45wrHa", 
         api_secret: "e49bfedb324637c920a628ebf3461891e8790977b9bf590522cdbfb67d13fd55",
         judo_id: "100039-783"}
end
JUDOPAY = {}
JUDOPAY[:host] = judo_info[:host]
JUDOPAY[:token] = judo_info[:api_token]
JUDOPAY[:secret] = judo_info[:api_secret]
JUDOPAY[:id] = judo_info[:judo_id] 
