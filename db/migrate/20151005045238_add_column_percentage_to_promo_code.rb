class AddColumnPercentageToPromoCode < ActiveRecord::Migration
  def change
    add_column :vouchers, :percentage, :integer
  end
end
