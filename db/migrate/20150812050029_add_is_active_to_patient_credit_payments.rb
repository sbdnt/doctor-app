class AddIsActiveToPatientCreditPayments < ActiveRecord::Migration
  def change
    add_column :patient_credit_payments, :is_active, :boolean, default: true
    add_index :patient_credit_payments, :is_active
  end
end
