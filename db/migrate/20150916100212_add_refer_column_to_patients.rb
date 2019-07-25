class AddReferColumnToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :referred_by, :integer
    add_column :patients, :is_first_booking, :boolean, default: false
    add_index  :patients, :referred_by
  end
end
