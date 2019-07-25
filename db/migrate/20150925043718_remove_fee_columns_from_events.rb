class RemoveFeeColumnsFromEvents < ActiveRecord::Migration
  def change
    remove_column :events, :base_cost, :decimal, precision: 10, scale: 2
    remove_column :events, :vat, :decimal, precision: 10, scale: 2
    remove_column :events, :doctor_credit, :decimal, precision: 10, scale: 2
    remove_column :events, :doctor_fine, :decimal, precision: 10, scale: 2
    remove_column :events, :patient_credit, :decimal, precision: 10, scale: 2
    remove_column :events, :patient_fee, :decimal, precision: 10, scale: 2
    remove_column :events, :gpdq_income, :decimal, precision: 10, scale: 2
    remove_column :events, :gpdq_cost, :decimal, precision: 10, scale: 2

    remove_column :events, :doctor_credit_percent, :decimal, precision: 5, scale: 2 
    remove_column :events, :patient_fee_percent, :decimal, precision: 5, scale: 2
    remove_column :events, :gpdq_income_percent, :decimal, precision: 5, scale: 2
    remove_column :events, :gpdq_cost_percent, :decimal, precision: 5, scale: 2
  end
end
