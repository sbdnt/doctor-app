class CreateAppointmentEvents < ActiveRecord::Migration
  def change
    create_table :appointment_events do |t|
      t.integer :appointment_id, null: false
      t.integer :event_id, null: false
      t.string :message

      t.timestamps null: false
    end

    add_index :appointment_events, [:appointment_id, :event_id]
  end
end
