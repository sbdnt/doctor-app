class CreateAppointmentFees < ActiveRecord::Migration
  def change
    create_table :appointment_fees do |t|
      t.references :appointment
      t.references :price_item
      t.decimal :price, precision: 10, scale: 2
      t.integer :quantity

      t.timestamps null: false
    end
  end
end
