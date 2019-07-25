class AddDeletedAtToPriceItems < ActiveRecord::Migration
  def change
    add_column :price_items, :deleted_at, :datetime
    add_index :price_items, :deleted_at
  end
end
