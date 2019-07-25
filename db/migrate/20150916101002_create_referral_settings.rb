class CreateReferralSettings < ActiveRecord::Migration
  def change
    create_table :referral_settings do |t|
      t.decimal :refer_bonus, default: 10
      t.text :sms
      t.text :email
      t.text :facebook
      t.text :twitter

      t.timestamps null: false
    end
  end
end
