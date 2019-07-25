class AddIsPublishedToPriceList < ActiveRecord::Migration
  def change
    add_column :price_lists, :is_published, :boolean, default: true
  end
end
