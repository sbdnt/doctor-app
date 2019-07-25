class AddMoreFieldToDoctor < ActiveRecord::Migration
  def change
  	add_column :doctors, :first_name, :string
    add_column :doctors, :last_name, :string
    add_column :doctors, :role, :integer
    add_column :doctors, :gender, :integer
  end
end
