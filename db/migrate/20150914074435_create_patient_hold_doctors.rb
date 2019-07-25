class CreatePatientHoldDoctors < ActiveRecord::Migration
  def change
    create_table :patient_hold_doctors do |t|
      t.references :doctor, index: true, foreign_key: true
      t.references :patient, index: true, foreign_key: true
      t.datetime :hold_at
      t.datetime :release_at

      t.timestamps null: false
    end
  end
end
