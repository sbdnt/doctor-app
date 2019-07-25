class ChangePriceToPricePerUnitOnPriceItem < ActiveRecord::Migration
  def change
    rename_column :price_items, :price, :price_per_unit
  end
end
