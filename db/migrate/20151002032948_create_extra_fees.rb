class CreateExtraFees < ActiveRecord::Migration
  def change
    create_table :extra_fees do |t|
      t.string :name
      t.decimal :price, precision: 10, scale: 2
      t.string :extra_type
      t.timestamps null: false
    end
  end
end
