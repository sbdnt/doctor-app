class AddTransportToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :transport, :string, default: 'transit'
  end
end
