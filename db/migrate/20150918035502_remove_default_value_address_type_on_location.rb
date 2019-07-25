class RemoveDefaultValueAddressTypeOnLocation < ActiveRecord::Migration
  def change
    change_column_default :locations, :address_type, nil
  end
end
