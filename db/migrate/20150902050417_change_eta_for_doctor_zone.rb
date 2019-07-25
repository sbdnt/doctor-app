class ChangeEtaForDoctorZone < ActiveRecord::Migration
  def change
    change_column :doctor_zones, :eta, :integer
  end
end
