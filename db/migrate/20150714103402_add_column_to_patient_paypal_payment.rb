class AddColumnToPatientPaypalPayment < ActiveRecord::Migration
  def change
    add_column :patient_paypal_payments, :password_hash, :string
  end
end
