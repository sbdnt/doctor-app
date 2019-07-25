class AddPaymentableToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :paymentable_id, :integer
    add_column :appointments, :paymentable_type, :string
  end
end
