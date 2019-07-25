class AddColumnsToPatientHoldDoctor < ActiveRecord::Migration
  def change
    remove_reference :patient_hold_doctors, :patient, index: true
    add_column :patient_hold_doctors, :patientable_id, :integer
    add_column :patient_hold_doctors, :patientable_type, :string
    add_index :patient_hold_doctors, :patientable_id
  end
end
