class RemoveZonesCorveredFromDoctor < ActiveRecord::Migration
  def change
    remove_column :doctors, :zones_covered
  end
end
