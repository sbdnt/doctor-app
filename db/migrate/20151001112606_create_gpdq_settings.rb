class CreateGpdqSettings < ActiveRecord::Migration
  def change
    create_table :gpdq_settings do |t|
      t.string :name
      t.decimal :value, :precision => 10, :scale => 2
      t.integer :time_unit

      t.timestamps null: false
    end
  end
end
