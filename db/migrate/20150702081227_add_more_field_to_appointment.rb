class AddMoreFieldToAppointment < ActiveRecord::Migration
  def change
    add_column :appointments, :confirmed_on_way_at, :datetime
  end
end
