class CreateReasonCodes < ActiveRecord::Migration
  def change
    create_table :reason_codes do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
  end
end
