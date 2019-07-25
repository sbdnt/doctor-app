class CreateSubZones < ActiveRecord::Migration
  def change
    create_table :sub_zones do |t|
      t.references :zone
      t.string :name
      t.timestamps null: false
    end
  end
end
