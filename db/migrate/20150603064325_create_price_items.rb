class CreatePriceItems < ActiveRecord::Migration
  def change
    create_table :price_items do |t|
      t.string  :name
      t.string  :price
      t.string  :description
      t.integer :category_id
      t.boolean :is_default, default: false

      t.timestamps null: false
    end
  end
end
