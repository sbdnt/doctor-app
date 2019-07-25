class CreateReferralInfos < ActiveRecord::Migration
  def change
    create_table :referral_infos do |t|
      t.integer :referral_id
      t.integer :referred_user_id
      t.decimal :refer_amount
      t.boolean :was_bonused, default: false

      t.timestamps null: false
    end

    add_index :referral_infos, :referral_id
    add_index :referral_infos, :referred_user_id
  end
end
