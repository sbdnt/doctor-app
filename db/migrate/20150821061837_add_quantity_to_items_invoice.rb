class AddQuantityToItemsInvoice < ActiveRecord::Migration
  def change
    add_column :items_invoices, :quantity, :integer, default: 1
  end
end
