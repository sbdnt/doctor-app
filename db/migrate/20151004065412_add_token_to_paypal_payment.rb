class AddTokenToPaypalPayment < ActiveRecord::Migration
  def change
    add_column :patient_paypal_payments, :paypal_access_token, :string
  end
end
