class CreateDoctorZones < ActiveRecord::Migration
  def change
    create_table :doctor_zones do |t|
      t.references :doctor, index: true, foreign_key: true
      t.references :zone, index: true, foreign_key: true
      t.integer :eta

      t.timestamps null: false
    end
  end
end
