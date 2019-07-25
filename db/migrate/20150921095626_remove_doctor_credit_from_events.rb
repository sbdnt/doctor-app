class RemoveDoctorCreditFromEvents < ActiveRecord::Migration
  def change
    remove_column :events, :doctor_credit, :boolean
    remove_column :events, :doctor_fine, :boolean
    remove_column :events, :patient_credit, :boolean
    remove_column :events, :patient_fee, :boolean
  end
end
