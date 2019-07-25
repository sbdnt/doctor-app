class AddAvailableToDoctor < ActiveRecord::Migration
  def change
    add_column :doctors, :available, :boolean, default: false
  end
end
