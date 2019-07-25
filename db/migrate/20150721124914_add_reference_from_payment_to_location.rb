class AddReferenceFromPaymentToLocation < ActiveRecord::Migration
  def change
    add_reference :patient_paypal_payments, :location, index: true
    add_reference :patient_credit_payments, :location, index: true
  end
end
