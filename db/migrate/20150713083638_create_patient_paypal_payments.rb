class CreatePatientPaypalPayments < ActiveRecord::Migration
  def change
    create_table :patient_paypal_payments do |t|
      t.string :paypal_email
      t.string :paypal_pwd
      t.references :patient, index: true, foreign_key: true
      t.references :appointment, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
