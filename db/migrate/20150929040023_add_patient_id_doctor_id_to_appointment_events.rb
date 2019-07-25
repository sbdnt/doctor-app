class AddPatientIdDoctorIdToAppointmentEvents < ActiveRecord::Migration
  def change
    add_column :appointment_events, :patient_id, :integer
    add_index :appointment_events, :patient_id
    add_column :appointment_events, :doctor_id, :integer
    add_index :appointment_events, :doctor_id
  end
end
