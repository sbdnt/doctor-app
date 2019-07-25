class AddIndexToAppointmentEvents < ActiveRecord::Migration
  def change
    add_index :appointment_events, [:eventable_id, :eventable_type], name: "eventable_index"
  end
end
