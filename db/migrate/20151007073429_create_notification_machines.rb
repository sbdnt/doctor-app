class CreateNotificationMachines < ActiveRecord::Migration
  def change
    create_table :notification_machines do |t|
      t.integer :appointment_id
      t.integer :event_id
      t.integer :receiver_id
      t.integer :receiver_role
      t.string :message
      t.string :app_message

      t.timestamps null: false
    end

    add_index :notification_machines, :appointment_id
    add_index :notification_machines, :event_id
    add_index :notification_machines, :receiver_role
  end
end
