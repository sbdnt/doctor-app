class AddCanceledByToAppointment < ActiveRecord::Migration
  def change
  	add_column :appointments, :canceled_by, :integer
  end
end
