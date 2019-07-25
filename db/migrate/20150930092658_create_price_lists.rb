class CreatePriceLists < ActiveRecord::Migration
  def change
    create_table :price_lists do |t|
      t.string :name
      t.text :description
      t.decimal :price, precision: 10, scale: 2
      t.string :price_type
      t.timestamps null: false
    end
  end
end
