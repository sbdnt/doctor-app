class CreateGpdqPhones < ActiveRecord::Migration
  def change
    create_table :gpdq_phones do |t|
      t.string :department
      t.string :phone_number
      t.boolean :is_published, default: false

      t.timestamps null: false
    end
  end
end
