class RemoveProcessFromAppointmentEvents < ActiveRecord::Migration
  def change
    remove_column :appointment_events, :process, :boolean
  end
end
