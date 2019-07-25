class EditLocationModel < ActiveRecord::Migration
  def change
  	add_column :locations, :address_type, :integer, default: 0
  end
end
