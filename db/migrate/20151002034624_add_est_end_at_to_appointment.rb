class AddEstEndAtToAppointment < ActiveRecord::Migration
  def change
    add_column :appointments, :est_end_at, :datetime
  end
end
