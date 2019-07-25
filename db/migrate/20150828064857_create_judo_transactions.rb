class CreateJudoTransactions < ActiveRecord::Migration
  def change
    create_table :judo_transactions do |t|
      t.references :appointment
      t.integer :payment_type
      t.integer :status
      t.float :amount
      t.string :consumer_token
      t.string :your_consumer_reference
      t.string :currency
      t.float :net_amount
      t.string :receipt_id
      t.string :your_payment_reference
      t.string :card_type

      t.timestamps null: false
    end
  end
end
