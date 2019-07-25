class AddAddressToZones < ActiveRecord::Migration
  def change
    add_column :zones, :address, :string
  end
end
