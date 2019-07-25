class CreateApplySchedules < ActiveRecord::Migration
  def change
    create_table :apply_schedules do |t|
      t.boolean :is_apply
      t.datetime :on_date
      t.references :doctor, index: true, foreign_key: true
      t.references :agency, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
