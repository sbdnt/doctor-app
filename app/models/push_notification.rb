require 'gcm'

# Android Push
# pusher = PushNotification.new(platform: "android", for_app: "doctor")
## USED 1:
## pusher.push_event(device_token: ["device_token_1", "device_token_2"], message: "Message", custom: {}, event_type: "dispached_doctor")
## ------
## USED 2:
## custom_data = { 
##   appointment_id: 1, 
##   app_message: "Message in app" # This key MUST HAVE and it is used for message display in app
## }
## pusher.push_event(device_token: ["device_token"], message: "test message", custom: custom_data, event_type: "dispached_doctor")

# Ios push
# pusher = PushNotification.new(platform: "ios", for_app: "doctor")
## USED 1:
## pusher.push_event(device_token: "device_token", message: "Message", custom: {}, event_type: "dispached_doctor")
# -------
## USED 2
## custom_data = { 
##   appointment_id: 1, 
##   app_message: "Message in app" # This key MUST HAVE and it is used for message display in app
## }
## pusher.push_event(device_token: "device_token", message: "Message", custom: custom_data, event_type: "dispached_doctor")

class PushNotification

  attr_accessor :platform, :pusher

  def initialize(platform: "ios", for_app: "patient")
    @platform = platform
    case @platform
    when "ios"
      certificate_file_url = if for_app == "doctor"
        "#{Rails.root}/lib/assets/pem_sandbox/doctor.pem"
      else
        "#{Rails.root}/lib/assets/pem_sandbox/patient.pem"
      end
      @pusher = Grocer.pusher(
        certificate: certificate_file_url,
        passphrase: "",
        gateway: "gateway.sandbox.push.apple.com",
        port: 2195,
        retries: 3
      )
    when "android"
      @pusher = if for_app == "doctor"
        GCM.new("AIzaSyAcLmYxUWJHqR6kq0OqVsfce770f5IxrO0")
      else
        GCM.new("AIzaSyAiw6JZnmrFnCLTQIU6YOwPYmUBkjrHT10")
      end
    end
  end

  def push_event(options)
    return false if !options[:message].present?
    message = options.delete(:message)
    custom_data = options.delete(:custom)
    event_type = options.delete(:event_type)
    case @platform
    when "ios"
      new_options = {
        # device_token: "75780f0c1d2824cd557e3af4a7ff2554fb4e7542d90c731ee17904c00ad2cb5b",
        alert: message,
        badge: 1,
        sound: "siren.aiff", 
        expiry: Time.now + 60*60,
        content_available: true,
        custom: {
          event_type: event_type,
          data: custom_data
        }
      }.merge(options)
      puts "===== options #{options}"
      puts "===== new_options #{new_options}"

      notification = Grocer::Notification.new(new_options)
      @pusher.push(notification)
    when "android"
      registration_ids = options[:device_token]
      new_options = {
        data: {
          title: "GPDQ",
          message: message,
          badge: 1,
          event_type: event_type,
          data: custom_data
        },
        collapse_key: "Notification"
      }.merge(options)
      puts "===== new options #{new_options}"
      puts "===== options #{options}"
      # Merge custom data
      # new_options[:data] = new_options[:data].merge(options[:custom])
      response = @pusher.send(registration_ids, new_options)
    end
  end
end