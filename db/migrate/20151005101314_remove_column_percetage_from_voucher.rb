class RemoveColumnPercetageFromVoucher < ActiveRecord::Migration
  def change
  	remove_column :vouchers, :percentage
  end
end
