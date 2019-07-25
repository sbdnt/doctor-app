class AddTimeToTempPatient < ActiveRecord::Migration
  def change
  	add_column :temp_patients, :changed_at, :datetime
  end
end
