class AddFeesColumnsToAppointmentEvents < ActiveRecord::Migration
  def change
    add_column :appointment_events, :base_cost, :decimal, precision: 10, scale: 2
    add_column :appointment_events, :vat, :decimal, precision: 10, scale: 2
    add_column :appointment_events, :doctor_credit, :decimal, precision: 10, scale: 2
    add_column :appointment_events, :doctor_fine, :decimal, precision: 10, scale: 2
    add_column :appointment_events, :patient_credit, :decimal, precision: 10, scale: 2
    add_column :appointment_events, :patient_fee, :decimal, precision: 10, scale: 2
    add_column :appointment_events, :gpdq_income, :decimal, precision: 10, scale: 2
    add_column :appointment_events, :gpdq_cost, :decimal, precision: 10, scale: 2
  end
end
