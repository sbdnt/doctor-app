class AddTwoFieldsToAppointment < ActiveRecord::Migration
  def change
  	add_column :appointments, :canceled_by_id, :integer
	add_column :appointments, :canceled_by_type, :string
  end
end
