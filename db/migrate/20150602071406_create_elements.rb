class CreateElements < ActiveRecord::Migration
  def change
    create_table :elements do |t|
      t.string :name
      t.string :phone
      t.string :address
      t.datetime :open_at
      t.datetime :close_at
      t.references :category

      t.timestamps null: false
    end
  end
end
