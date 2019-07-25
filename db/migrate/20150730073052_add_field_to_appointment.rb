class AddFieldToAppointment < ActiveRecord::Migration
  def change
    add_column :appointments, :is_referred, :boolean, default: false 
  end
end
