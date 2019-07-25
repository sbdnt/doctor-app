class ChangeTypeLatLngDoctors < ActiveRecord::Migration
  def change
    change_column :doctors, :latitude, :decimal, precision: 12, scale: 8
    change_column :doctors, :longitude, :decimal, precision: 12, scale: 8
  end
end
