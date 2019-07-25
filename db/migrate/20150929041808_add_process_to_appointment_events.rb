class AddProcessToAppointmentEvents < ActiveRecord::Migration
  def change
    add_column :appointment_events, :process, :boolean
    add_index :appointment_events, :process
  end
end
