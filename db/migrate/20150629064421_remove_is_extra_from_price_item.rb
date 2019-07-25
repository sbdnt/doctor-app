class RemoveIsExtraFromPriceItem < ActiveRecord::Migration
  def change
    remove_column :price_items, :is_extra
  end
end
