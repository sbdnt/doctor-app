class ChangeFloatToDecimalOnItemsInvoiceInvoice < ActiveRecord::Migration
  def up
    change_column :items_invoices, :item_price, :decimal, precision: 10, scale: 2
    change_column :invoices, :total_prices, :decimal, precision: 10, scale: 2
    change_column :invoices, :total_extra, :decimal, precision: 10, scale: 2
  end

  def down
    change_column :items_invoices, :item_price, :float
    change_column :invoices, :total_prices, :float
    change_column :invoices, :total_extra, :float
  end
end
