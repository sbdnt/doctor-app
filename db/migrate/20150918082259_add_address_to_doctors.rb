class AddAddressToDoctors < ActiveRecord::Migration
  def change
    add_column :doctors, :address, :string
  end
end
