class AddCodeToAgency < ActiveRecord::Migration
  def change
    add_column :agencies, :sort_code, :string
  end
end
