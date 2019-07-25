class AddIndexAppointmentIdToAppointmentEvents < ActiveRecord::Migration
  def change
    add_index :appointment_events, :appointment_id
  end
end
