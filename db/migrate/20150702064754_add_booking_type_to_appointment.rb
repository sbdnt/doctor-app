class AddBookingTypeToAppointment < ActiveRecord::Migration
  def change
    add_column :appointments, :booking_type, :integer, default: 0
  end
end
