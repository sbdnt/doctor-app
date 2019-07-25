class AddDoctorCreditToEvents < ActiveRecord::Migration
  def change
    add_column :events, :base_cost, :decimal, precision: 10, scale: 2
    add_column :events, :vat, :decimal, precision: 10, scale: 2
    add_column :events, :doctor_credit, :decimal, precision: 10, scale: 2
    add_column :events, :doctor_fine, :decimal, precision: 10, scale: 2
    add_column :events, :patient_credit, :decimal, precision: 10, scale: 2
    add_column :events, :patient_fee, :decimal, precision: 10, scale: 2
    add_column :events, :gpdq_income, :decimal, precision: 10, scale: 2
    add_column :events, :gpdq_cost, :decimal, precision: 10, scale: 2
  end
end
