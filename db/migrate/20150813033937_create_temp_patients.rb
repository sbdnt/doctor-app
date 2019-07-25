class CreateTempPatients < ActiveRecord::Migration
  def change
    create_table :temp_patients do |t|
      t.string :session_value
      t.float :latitude
      t.float :longitude
      t.string :address
      t.integer :zone_id

      t.timestamps null: false
    end
  end
end
