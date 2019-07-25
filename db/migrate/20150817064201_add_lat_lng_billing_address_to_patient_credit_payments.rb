class AddLatLngBillingAddressToPatientCreditPayments < ActiveRecord::Migration
  def change
    add_column :patient_credit_payments, :lat_bill_address, :decimal, precision: 12, scale: 8
    add_column :patient_credit_payments, :lng_bill_address, :decimal, precision: 12, scale: 8
    add_column :patient_credit_payments, :bill_address, :string
  end
end
