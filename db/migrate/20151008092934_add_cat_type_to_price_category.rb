class AddCatTypeToPriceCategory < ActiveRecord::Migration
  def change
    add_column :price_categories, :cat_type, :string
  end
end
