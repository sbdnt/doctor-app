class AddEditableToPriceItem < ActiveRecord::Migration
  def change
    add_column :price_items, :editable, :boolean, default: true
  end
end
