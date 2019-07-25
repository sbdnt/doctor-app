class AddPriceTypeToPriceItem < ActiveRecord::Migration
  def change
    add_column :price_items, :price_type , :string
  end
end
