class CreatePeriods < ActiveRecord::Migration
  def change
    create_table :periods do |t|
      t.references :schedule, index: true, foreign_key: true
      t.integer :agency_status
      t.integer :duration
      t.datetime :start_at
      t.datetime :end_at
      t.integer :doctor_status
      t.references :appointment, index: true, foreign_key: true
      t.references :custom_schedule, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
