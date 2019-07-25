class AddTokenToAgencyDoctor < ActiveRecord::Migration
  def change
    add_column :agencies, :auth_token, :string
    add_column :doctors, :auth_token, :string
  end
end
