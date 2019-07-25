class AddAuthorizationIdToPaypalTransaction < ActiveRecord::Migration
  def change
    add_column :paypal_transactions, :authorization_id, :string
  end
end
