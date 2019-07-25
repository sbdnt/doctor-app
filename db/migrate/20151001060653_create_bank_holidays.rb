class CreateBankHolidays < ActiveRecord::Migration
  def change
    create_table :bank_holidays do |t|
      t.date :event_date
      t.string :event_name
      t.timestamps null: false
    end
  end
end
