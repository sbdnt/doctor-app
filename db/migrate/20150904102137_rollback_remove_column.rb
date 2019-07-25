class RollbackRemoveColumn < ActiveRecord::Migration
  def change
    add_reference :appointment_fees, :price_item, index: true
    remove_column :appointment_fees, :item_name
    remove_column :items_invoices, :is_default
  end
end
