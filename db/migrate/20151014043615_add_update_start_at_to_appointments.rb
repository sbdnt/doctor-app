class AddUpdateStartAtToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :update_start_at, :datetime
  end
end
