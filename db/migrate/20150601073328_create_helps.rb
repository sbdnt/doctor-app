class CreateHelps < ActiveRecord::Migration
  def change
    create_table :helps do |t|
      t.string :title
      t.text :content

      t.timestamps null: false
    end
  end
end
