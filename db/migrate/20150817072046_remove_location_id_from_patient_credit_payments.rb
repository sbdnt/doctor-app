class RemoveLocationIdFromPatientCreditPayments < ActiveRecord::Migration
  def change
    remove_column :patient_credit_payments, :location_id, :integer
  end
end
