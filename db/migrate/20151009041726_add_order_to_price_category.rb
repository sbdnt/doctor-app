class AddOrderToPriceCategory < ActiveRecord::Migration
  def change
    add_column :price_categories, :category_order, :integer
  end
end
