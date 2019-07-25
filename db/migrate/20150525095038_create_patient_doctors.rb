class CreatePatientDoctors < ActiveRecord::Migration
  def change
    create_table :patient_doctors do |t|
      t.references :patient, index: true, foreign_key: true
      t.references :doctor, index: true, foreign_key: true
      t.integer :eta

      t.timestamps null: false
    end
  end
end
