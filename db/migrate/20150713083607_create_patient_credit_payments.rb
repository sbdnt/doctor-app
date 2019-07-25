class CreatePatientCreditPayments < ActiveRecord::Migration
  def change
    create_table :patient_credit_payments do |t|
      t.string :cc_num
      t.string :expiry
      t.string :cvc
      t.integer :cc_type
      t.string :billing_address
      t.references :patient, index: true, foreign_key: true
      t.references :appointment, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
