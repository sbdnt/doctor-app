class AddIsBillAddressToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :is_bill_address, :boolean, default: false
  end
end
