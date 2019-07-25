class AddColumnToAppointment < ActiveRecord::Migration
  def change
    add_column :appointments, :is_canceled, :integer, default: 0
    add_column :appointments, :payment_status, :integer
  end
end
