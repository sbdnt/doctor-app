class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :type_name, null: false
      t.integer :category, null: false
      t.boolean :standard, null: false
      t.boolean :created_via_back_end
      t.boolean :created_via_app
      t.boolean :created_manual
      t.integer :reason_code_id
      t.boolean :doctor_sms
      t.boolean :doctor_push
      t.boolean :patient_sms
      t.boolean :patient_push
      t.boolean :in_app_alert
      t.boolean :doctor_credit
      t.boolean :doctor_fine
      t.boolean :patient_credit
      t.boolean :patient_fee

      t.timestamps null: false
    end
    add_index :events, :category
    add_index :events, :standard
    add_index :events, :reason_code_id
  end
end
