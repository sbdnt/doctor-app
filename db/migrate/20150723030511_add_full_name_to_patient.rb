class AddFullNameToPatient < ActiveRecord::Migration
  def change
    add_column :patients, :fullname, :string
  end
end
