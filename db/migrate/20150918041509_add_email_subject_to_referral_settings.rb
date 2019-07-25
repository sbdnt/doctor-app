class AddEmailSubjectToReferralSettings < ActiveRecord::Migration
  def change
    add_column :referral_settings, :email_subject, :string, default: 'Referral email from GPDQ'
  end
end
