class AddStatusToAgency < ActiveRecord::Migration
  def change
    add_column :agencies, :status, :integer, default: 0
  end
end
