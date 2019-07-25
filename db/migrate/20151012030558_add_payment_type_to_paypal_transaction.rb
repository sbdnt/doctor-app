class AddPaymentTypeToPaypalTransaction < ActiveRecord::Migration
  def change
    add_column :paypal_transactions, :payment_type, :integer
  end
end
