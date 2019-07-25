class AddSponsorIdToVouchers < ActiveRecord::Migration
  def change
    add_column :vouchers, :sponsor_id, :integer
  end
end
