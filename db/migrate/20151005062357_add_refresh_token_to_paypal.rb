class AddRefreshTokenToPaypal < ActiveRecord::Migration
  def change
    add_column :patient_paypal_payments, :refresh_token, :string
  end
end
