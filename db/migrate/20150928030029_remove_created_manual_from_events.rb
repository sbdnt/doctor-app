class RemoveCreatedManualFromEvents < ActiveRecord::Migration
  def change
    remove_column :events, :created_manual, :boolean
  end
end
