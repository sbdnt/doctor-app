class AddColumnsToPatient < ActiveRecord::Migration
  def change
    add_column :patients, :platform, :string
  end
end
