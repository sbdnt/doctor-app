class AddTransportToPatientDoctors < ActiveRecord::Migration
  def change
    add_column :patient_doctors, :transport, :string
  end
end
