class AddMoreFieldToAgency < ActiveRecord::Migration
  def change
    add_column :agencies, :first_name, :string
    add_column :agencies, :last_name, :string
    add_column :agencies, :role, :integer
    add_column :agencies, :gender, :integer
  end
end
