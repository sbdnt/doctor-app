class ChangeEtaForPatientDoctor < ActiveRecord::Migration
  def change
  	change_column :patient_doctors, :eta, :float
  end
end
