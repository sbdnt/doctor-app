class AddColumnsToAppointment < ActiveRecord::Migration
  def change
    add_column :appointments, :rating, :integer
    add_column :appointments, :feedback, :text
  end
end
