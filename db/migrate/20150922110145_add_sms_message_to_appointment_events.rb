class AddSmsMessageToAppointmentEvents < ActiveRecord::Migration
  def change
    add_column :appointment_events, :sms_message, :string
    add_column :appointment_events, :notification_message, :string
  end
end
