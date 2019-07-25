class RenameIsFirstBookingColumnPatients < ActiveRecord::Migration
  def change
    rename_column :patients, :is_first_booking, :got_first_booking
  end
end
