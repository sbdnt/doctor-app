class AddDoctorCreditPercentToEvents < ActiveRecord::Migration
  def change
    add_column :events, :doctor_credit_percent, :decimal, precision: 5, scale: 2 
    add_column :events, :patient_fee_percent, :decimal, precision: 5, scale: 2
    add_column :events, :gpdq_income_percent, :decimal, precision: 5, scale: 2
    add_column :events, :gpdq_cost_percent, :decimal, precision: 5, scale: 2
  end
end
