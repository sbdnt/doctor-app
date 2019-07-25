class AddHoldToDoctor < ActiveRecord::Migration
  def change
    add_column :doctors, :is_hold, :boolean, :default => false
  end
end
