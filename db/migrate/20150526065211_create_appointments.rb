class CreateAppointments < ActiveRecord::Migration
  def change
    create_table :appointments do |t|
      t.references :doctor, index: true, foreign_key: true
      t.references :patient, index: true, foreign_key: true
      t.datetime :start_at
      t.datetime :end_at
      t.integer :duration
      t.string :description
      t.integer :status

      t.timestamps null: false
    end
  end
end
