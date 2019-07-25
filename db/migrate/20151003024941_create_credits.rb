class CreateCredits < ActiveRecord::Migration
  def change
    create_table :credits do |t|
      t.references :patient, index: true, foreign_key: true
      t.integer :appointment_id
      t.integer :patient_reference_id
      t.decimal :credit_number, :precision => 8, :scale => 2
      t.date :expired_date
      t.boolean :is_used, default: false
      t.integer :credit_type
      t.date :used_at
      t.integer :used_appointment_id

      t.timestamps null: false
    end
  end
end
