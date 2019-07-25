class AddDiscountToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :discount, :decimal, precision: 10, scale: 2, default: 0
  end
end
