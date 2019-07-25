class AddTransitToDoctor < ActiveRecord::Migration
  def change
    add_column :doctors, :is_transit, :boolean, default: false
  end
end
