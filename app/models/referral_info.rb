class ReferralInfo < ActiveRecord::Base
  belongs_to :referral, class_name: 'ReferralCode', foreign_key: 'referral_id'
  belongs_to :referred_user, class_name: "Patient", foreign_key: 'referred_user_id'

  validates :referral_id, :referred_user_id, :refer_amount, presence: true

  # after_create :send_bonus_to_referred_user

  def send_bonus_to_referred_user
    referred_user_email = self.referred_user.try(:email)
    voucher = Voucher.auto_generate_code(self.refer_amount)
    PatientMailer.referred_user_bonus_email(referred_user_email, voucher.voucher_code).deliver_now
  end

end
