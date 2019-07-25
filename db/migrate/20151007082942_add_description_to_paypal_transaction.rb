class AddDescriptionToPaypalTransaction < ActiveRecord::Migration
  def change
    add_column :paypal_transactions, :description, :string
  end
end
