class AddFreeTextToAppointmentEvent < ActiveRecord::Migration
  def change
    add_column :appointment_events, :free_text, :text
  end
end
