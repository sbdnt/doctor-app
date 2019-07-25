class AddEditPriceToPriceCategory < ActiveRecord::Migration
  def change
    add_column :price_categories, :allow_edit_price, :boolean, default: false
  end
end
