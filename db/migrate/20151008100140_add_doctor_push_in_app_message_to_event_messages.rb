class AddDoctorPushInAppMessageToEventMessages < ActiveRecord::Migration
  def change
    add_column :event_messages, :doctor_push_in_app, :string
    add_column :event_messages, :patient_push_in_app, :string
  end
end
