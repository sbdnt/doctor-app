class CreatePaypalTransactions < ActiveRecord::Migration
  def change
    create_table :paypal_transactions do |t|
      t.references :appointment, index: true
      t.integer :status
      t.decimal :amount, precision: 10, scale: 2
      t.string :payment_id
      t.string :currency, default: "GBP"
      t.timestamps null: false
    end
  end
end
