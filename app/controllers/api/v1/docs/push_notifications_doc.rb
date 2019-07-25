class Api::V1::Docs::PushNotificationsDoc < ActionController::Base
  def self.general(event_type:)
    <<-EOS
      Structure data:
      - iOS:
        {
          event_type = "#{event_type}",
          aps =     {
              alert = "Message show in notification",
              badge = 1,
              "content-available" = 1,
              sound = "siren.aiff"
          },
          data = {
            "app_message" = "Message is shown in app",
            "appointment_id" = 123,
          }
        }

      - android:
        {
          data: {
            title: "GPDQ",
            message: "Message show in notification",
            badge: 1,
            event_type: "#{event_type}",
            data: {
              appointment_id: 123,
              app_message: "Message is shown in app"
            }
          },
          collapse_key: "Notification"
        }
    EOS
  end
end