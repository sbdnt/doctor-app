class ChangeDataTypeItemInvoicePriceItem < ActiveRecord::Migration
  def change
    change_column :items_invoices, :item_price, 'float USING CAST(item_price AS float)'
    change_column :price_items, :price, 'float USING CAST(price AS float)'
    change_column :invoices, :total_prices, 'float USING CAST(total_prices AS float)'
  end
end
