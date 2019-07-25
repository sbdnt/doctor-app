class CreateItemsInvoices < ActiveRecord::Migration
  def change
    create_table :items_invoices do |t|
      t.references :price_item, index: true, foreign_key: true
      t.references :invoice, index: true, foreign_key: true
      t.string :item_price
    end
  end
end
