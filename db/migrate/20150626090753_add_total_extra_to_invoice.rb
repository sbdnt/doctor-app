class AddTotalExtraToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :total_extra, :float, default: 0
  end
end
