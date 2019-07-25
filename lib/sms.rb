require 'net/http'
require 'uri'
module SMS
  def self.send_sms(to, message, originator)
    requested_url = 'http://api.textmarketer.co.uk/gateway/?option=xml' +
                  "&username=" + TEXT_SMS[:username] + "&password=" + TEXT_SMS[:password] +
                  "&to=" + to + "&message=" + URI.escape(message) +
                  "&orig=" + URI.escape(originator)
    url = URI.parse(requested_url)
    full_path = (url.query.blank?) ? url.path : "#{url.path}?#{url.query}"
    the_request = Net::HTTP::Get.new(full_path)
    the_response = Net::HTTP.start(url.host, url.port) { |http|
      http.request(the_request)
    }
    raise "Response was not 200, response was #{the_response.code}" if the_response.code != "200"
    res = Hash.from_xml(the_response.body).symbolize_keys[:response].symbolize_keys

    return res
  end
  # resp = send_sms('myUsername', 'myPassword', '4477777777', 'My test message', 'TextMessage')
   
  # puts(resp)
end