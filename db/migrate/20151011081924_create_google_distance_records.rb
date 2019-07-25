class CreateGoogleDistanceRecords < ActiveRecord::Migration
  def change
    create_table :google_distance_records do |t|
      t.string :origin
      t.string :destination
      t.string :transportation
      t.float :duration
      t.float :distance
      t.boolean :no_result, default: false

      t.timestamps null: false
    end
  end
end
