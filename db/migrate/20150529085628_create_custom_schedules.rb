class CreateCustomSchedules < ActiveRecord::Migration
  def change
    create_table :custom_schedules do |t|
      t.references :schedule, index: true, foreign_key: true
      t.datetime :working_date
      t.integer :week_day
      t.datetime :start_time
      t.datetime :end_time
      t.references :doctor, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
