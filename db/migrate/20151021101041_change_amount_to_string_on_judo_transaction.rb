class ChangeAmountToStringOnJudoTransaction < ActiveRecord::Migration
  def up
    change_column :judo_transactions, :amount, :string
    change_column :judo_transactions, :net_amount, :string
  end

  def down
    change_column :judo_transactions, :amount, :float
    change_column :judo_transactions, :net_amount, :float
  end
end
