class AddIsExtraToPriceItem < ActiveRecord::Migration
  def change
    add_column :price_items, :is_extra, :boolean, default: false
  end
end
