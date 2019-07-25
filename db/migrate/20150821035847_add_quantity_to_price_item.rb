class AddQuantityToPriceItem < ActiveRecord::Migration
  def change
    add_column :price_items, :quantity, :integer, default: 1
  end
end
