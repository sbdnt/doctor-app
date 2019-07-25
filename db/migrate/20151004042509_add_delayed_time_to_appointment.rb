class AddDelayedTimeToAppointment < ActiveRecord::Migration
  def change
    add_column :appointments, :delayed_time, :integer, default: 0
  end
end
