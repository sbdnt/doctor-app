class AddTimeToPatient < ActiveRecord::Migration
  def change
    add_column :patients, :changed_at, :datetime
  end
end
