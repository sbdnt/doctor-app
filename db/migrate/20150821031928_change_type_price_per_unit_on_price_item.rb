class ChangeTypePricePerUnitOnPriceItem < ActiveRecord::Migration
  def up
    change_column :price_items, :price_per_unit, :decimal, precision: 10, scale: 2
  end
  def down
    change_column :price_items, :price_per_unit, :float
  end
end
