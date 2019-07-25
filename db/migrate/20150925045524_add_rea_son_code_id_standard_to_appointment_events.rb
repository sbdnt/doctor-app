class AddReaSonCodeIdStandardToAppointmentEvents < ActiveRecord::Migration
  def change
    add_column :appointment_events, :reason_code_id, :integer
    add_column :appointment_events, :standard, :boolean
    add_index :appointment_events, :reason_code_id
  end
end
