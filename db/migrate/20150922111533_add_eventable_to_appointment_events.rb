class AddEventableToAppointmentEvents < ActiveRecord::Migration
  def change
    add_column :appointment_events, :eventable_id, :integer
    add_column :appointment_events, :eventable_type, :string
  end
end
