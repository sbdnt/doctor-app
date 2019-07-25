class AddOrderToPriceList < ActiveRecord::Migration
  def change
    add_column :price_lists, :order, :integer
  end
end
