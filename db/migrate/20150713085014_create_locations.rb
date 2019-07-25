class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :address
      t.boolean :is_current
      t.references :patient, index: true, foreign_key: true
      t.float :latitude
      t.float :longitude

      t.timestamps null: false
    end
  end
end
