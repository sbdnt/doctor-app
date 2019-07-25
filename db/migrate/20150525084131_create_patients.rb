class CreatePatients < ActiveRecord::Migration
  def change
    create_table :patients do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.text :fb_id
      t.text :device_token
      t.string :avatar
      t.text :fb_token
      t.text :auth_token
      t.float :latitude
      t.float :longitude
      t.string :address
      t.integer :zone_id

      t.timestamps null: false
    end
  end
end
