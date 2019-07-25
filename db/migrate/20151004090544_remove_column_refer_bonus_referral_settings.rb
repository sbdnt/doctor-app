class RemoveColumnReferBonusReferralSettings < ActiveRecord::Migration
  def change
    remove_column :referral_settings, :refer_bonus, :decimal
  end
end
