class AddLatLngAddressesToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :lat, :decimal, precision: 12, scale: 8
    add_column :appointments, :lng, :decimal, precision: 12, scale: 8
    add_column :appointments, :address, :string
    add_column :appointments, :lat_bill_address, :decimal, precision: 12, scale: 8
    add_column :appointments, :lng_bill_address, :decimal, precision: 12, scale: 8
    add_column :appointments, :bill_address, :string
  end
end
