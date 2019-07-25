class AddIsPublishedToHelp < ActiveRecord::Migration
  def change
    add_column :helps, :is_published, :boolean, default: false
  end
end
