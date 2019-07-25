class CreateEventMessages < ActiveRecord::Migration
  def change
    create_table :event_messages do |t|
      t.integer :event_id
      t.integer :reason_code_id
      t.string :doctor_sms
      t.string :doctor_push
      t.string :patient_sms
      t.string :patient_push

      t.timestamps null: false
    end

    add_index :event_messages, [:event_id, :reason_code_id]
  end
end
