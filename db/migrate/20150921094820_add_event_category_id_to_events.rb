class AddEventCategoryIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :event_category_id, :integer
    add_index :events, :event_category_id
  end
end
