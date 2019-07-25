class CreateReferrals < ActiveRecord::Migration
  def change
    create_table :referrals do |t|
      t.integer :invitor_id
      t.string :referral_code

      t.timestamps null: false
    end
  end
end
