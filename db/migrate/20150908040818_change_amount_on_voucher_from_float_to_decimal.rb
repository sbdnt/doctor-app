class ChangeAmountOnVoucherFromFloatToDecimal < ActiveRecord::Migration
  def up
    change_column :vouchers, :amount, :decimal, precision: 10, scale: 2
  end

  def down
    change_column :vouchers, :amount, :float
  end
end
