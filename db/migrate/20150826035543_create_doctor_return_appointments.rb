class CreateDoctorReturnAppointments < ActiveRecord::Migration
  def change
    create_table :doctor_return_appointments do |t|
      t.references :doctor
      t.references :appointment

      t.timestamps null: false
    end
  end
end
