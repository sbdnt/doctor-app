class AddFieldToPatientDoctor < ActiveRecord::Migration
  def change
    add_column :patient_doctors, :km, :float 
  end
end
