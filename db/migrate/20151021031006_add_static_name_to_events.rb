class AddStaticNameToEvents < ActiveRecord::Migration
  def change
    add_column :events, :static_name, :string
    add_index :events, :static_name
  end
end
