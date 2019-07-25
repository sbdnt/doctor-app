class AddIsDefaultToItemsInvoice < ActiveRecord::Migration
  def change
    add_column :items_invoices, :is_default, :boolean, default: false
  end
end
