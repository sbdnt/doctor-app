class AddIsProcessedToAppointmentEvents < ActiveRecord::Migration
  def change
    add_column :appointment_events, :is_processed, :boolean, default: true
    add_index :appointment_events, [:appointment_id, :is_processed]
  end
end
