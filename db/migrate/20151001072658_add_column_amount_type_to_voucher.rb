class AddColumnAmountTypeToVoucher < ActiveRecord::Migration
  def change
    add_column :vouchers, :type, :string, null: false, default: 'PromoCode'
    add_column :vouchers, :description, :text
    add_column :vouchers, :is_percentage, :boolean, default: false
    add_column :vouchers, :started_date, :datetime
    add_column :vouchers, :ended_date, :datetime
  end
end
