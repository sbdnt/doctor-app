class AddMethodToDoctors < ActiveRecord::Migration
  def change
    add_column :doctors, :transportation, :string
  end
end
