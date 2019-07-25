class AddTimeToAppointment < ActiveRecord::Migration
  def change
  	add_column :appointments, :assigned_time_at, :datetime
  end
end
