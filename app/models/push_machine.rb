class PushMachine < ActiveRecord::Base

  # ASSOCIATIONS
  belongs_to :appointment
  belongs_to :event

  # SCOPES

  # ENUMS
  enum receiver_role: { patient: 1, doctor: 2 }

  # VALIDATIONS
  validates :appointment_id, :event_id, :receiver_id, :receiver_role,
    :message, :app_message, presence: true

  # CALLBACKS
  after_save :send_push

  def send_push
    for_app = "patient"
    receiver = if false
      Patient.where(id: receiver_id).first
    else
      for_app = "doctor"
      Doctor.where(id: receiver_id).first
    end
    if receiver && receiver.device_token && receiver.platform
      device_token = receiver.device_token
      platform = receiver.platform

      pusher = PushNotification.new(platform: platform, for_app: for_app)
      custom_data = { 
        appointment_id: appointment_id,
        app_message: app_message
      }

      event_type = event.name_for_push
      case platform
      when "ios"
        pusher.push_event(device_token: device_token, message: message, custom: custom_data, event_type: event_type)
      when "android"
        pusher.push_event(device_token: [device_token], message: message, custom: custom_data, event_type: event_type)
      end
    end
  end
end
