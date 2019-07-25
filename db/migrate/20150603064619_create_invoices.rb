class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.string :total_prices
      t.integer :appointment_id

      t.timestamps null: false
    end
  end
end
