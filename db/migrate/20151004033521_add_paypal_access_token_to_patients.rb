class AddPaypalAccessTokenToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :paypal_access_token, :string
  end
end
