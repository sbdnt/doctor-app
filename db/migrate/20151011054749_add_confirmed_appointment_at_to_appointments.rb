class AddConfirmedAppointmentAtToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :confirmed_appointment_at, :datetime
  end
end
