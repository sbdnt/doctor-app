class SmsSystem < ActiveRecord::Base
  require 'net/http'
  require 'uri'
  belongs_to :doctor
  belongs_to :patient
  belongs_to :event
  validates :to, presence: true
  validates :message, presence: true
  validates :originator, presence: true
  enum status: {failed: 0, success: 1}
  enum sent_via: {back_end: 0, app: 1}

  def self.send_and_track_sms(options = {})
    res = send_sms(options)

    sms = SmsSystem.new(to: options[:to], message: options[:message], originator: options[:originator])
    sms.patient_id = options[:patient_id] if options[:patient_id].present? && Patient.find_by(id: options[:patient_id]).present?
    sms.doctor_id = options[:doctor_id] if options[:doctor_id].present? && Doctor.find_by(id: options[:doctor_id]).present?
    sms.status = SmsSystem.statuses[res[:status]]
    sms.reason = res[:reason] if res[:reason].present?
    sms.sent_via = options[:sent_via].to_i if options[:sent_via].present?
    sms.event_id = options[:event_id] if options[:event_id].present? && Event.find_by(id: options[:event_id]).present?
    unless sms.save
      return {errors: sms.errors.full_messages}
    else
      return {status: res[:status], reason: res[:reason]}
    end
  end

  def self.send_sms(options = {})
    to = options[:to].gsub(/\s/,'').gsub('+','')
    requested_url = 'http://api.textmarketer.co.uk/gateway/?option=xml' +
                  "&username=" + TEXT_SMS[:username] + "&password=" + TEXT_SMS[:password] +
                  "&to=" + to + "&message=" + URI.escape(options[:message]) +
                  "&orig=" + URI.escape(options[:originator])
    url = URI.parse(requested_url)
    full_path = (url.query.blank?) ? url.path : "#{url.path}?#{url.query}"
    the_request = Net::HTTP::Get.new(full_path)
    the_response = Net::HTTP.start(url.host, url.port) { |http|
      http.request(the_request)
    }
    raise "Response was not 200, response was #{the_response.code}" if the_response.code != "200"
    res = Hash.from_xml(the_response.body).symbolize_keys[:response].symbolize_keys
  end
end
