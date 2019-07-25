class AddAllowExpandToPriceCategory < ActiveRecord::Migration
  def change
    add_column :price_categories, :allow_expand, :boolean, default: true
  end
end
