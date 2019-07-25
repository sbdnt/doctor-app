class AddNameForPushToEvents < ActiveRecord::Migration
  def change
    add_column :events, :name_for_push, :string
  end
end
