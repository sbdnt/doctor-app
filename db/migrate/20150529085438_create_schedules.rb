class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.datetime :working_date
      t.references :agency, index: true, foreign_key: true
      t.integer :week_day
      t.datetime :start_time
      t.datetime :end_time


      t.timestamps null: false
    end
  end
end
