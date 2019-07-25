class AddCreatedManualToAppointmentEvents < ActiveRecord::Migration
  def change
    add_column :appointment_events, :created_manual, :boolean
  end
end
