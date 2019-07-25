class CreateManualProcessEvents < ActiveRecord::Migration
  def change
    create_table :manual_process_events do |t|
      t.integer :event_id, null: false
      t.integer :reason_code_id
      t.boolean :manual_process, default: true

      t.timestamps null: false
    end

    add_index :manual_process_events, [:event_id, :reason_code_id], unique: true
  end
end
