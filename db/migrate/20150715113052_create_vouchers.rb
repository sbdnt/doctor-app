class CreateVouchers < ActiveRecord::Migration
  def change
    create_table :vouchers do |t|
      t.string :voucher_code
      t.float :amount
      t.boolean :is_used, default: false
      t.references :appointment, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
