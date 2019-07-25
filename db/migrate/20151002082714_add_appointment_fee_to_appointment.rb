class AddAppointmentFeeToAppointment < ActiveRecord::Migration
  def change
    add_column :appointments, :appointment_fee, :decimal, precision: 10, scale: 2
  end
end
