class RemoveLocationIdFromAppointments < ActiveRecord::Migration
  def change
    remove_column :appointments, :location_id, :integer
  end
end
