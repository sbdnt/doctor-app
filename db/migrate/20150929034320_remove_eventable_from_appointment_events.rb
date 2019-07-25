class RemoveEventableFromAppointmentEvents < ActiveRecord::Migration
  def change
    remove_column :appointment_events, :eventable_id, :integer
    remove_column :appointment_events, :eventable_type, :string
  end
end
