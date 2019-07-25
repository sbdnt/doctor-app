class CreateWorkingDays < ActiveRecord::Migration
  def change
    create_table :working_days do |t|
      t.datetime :close_at
      t.datetime :open_at
      t.references :element, index: true, foreign_key: true
      t.integer :week_day

      t.timestamps null: false
    end
  end
end
