class RenamePasswordFieldPatientPaypalPayment < ActiveRecord::Migration
  def change
    rename_column :patient_paypal_payments, :paypal_pwd, :password
  end
end
