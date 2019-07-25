class RenameTypeNameEvents < ActiveRecord::Migration
  def change
    rename_column :events, :type_name, :name
  end
end
