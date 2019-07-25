module Api
  module V1
    class PushNotificationsController < ActionController::Base

      resource_description do
        app_info "Push Notification Docs"
        api_versions "notifications"
        name "Notifications"
      end

      api! "Dispached to doctor event. This occurs when: Doctor is assigned to a confirmed booking"
      example Api::V1::Docs::PushNotificationsDoc.general(event_type: "dispached_doctor")
      def dispached_doctor
      end

      api! "Appointment complete event. This occurs when: Manually confirmed via Dr App"
      example Api::V1::Docs::PushNotificationsDoc.general(event_type: "appointment_complete")
      def appointment_complete
      end

      api! "Doctor confirmed on way event. This occurs when: Doctor confirms 'on way' in his app"
      example Api::V1::Docs::PushNotificationsDoc.general(event_type: "doctor_on_way")
      def doctor_on_way
      end

      api! "Patient Cancellation event. This occurs when patient select 'Cancel' from my upcomming appointment list "
      example Api::V1::Docs::PushNotificationsDoc.general(event_type: "patient_cancellation")
      def patient_cancellation
      end

      api! "Doctor confirmed appointment started event. This occurs when doctor select 'Appointment Started'"
      example Api::V1::Docs::PushNotificationsDoc.general(event_type: "dr_confirmed_appointment_started")
      def dr_confirmed_appointment_started
      end
    end
  end
end