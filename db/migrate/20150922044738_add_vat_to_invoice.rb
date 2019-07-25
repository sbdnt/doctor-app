class AddVatToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :vat, :decimal, precision: 10, scale: 2
  end
end
