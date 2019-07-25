class ReferralSetting < ActiveRecord::Base
  validates :sms, :email, :facebook, :twitter, :email_subject, presence: true
  after_initialize do
    default_content = 'Get {{refer_bonus}} off your first appointment by using my referral code: {{referral_code}}'
    self.sms = default_content if !self.sms.present?
    self.email = default_content if !self.email.present?
    self.facebook = default_content if !self.facebook.present?
    self.twitter = default_content if !self.twitter.present?
  end

  def refer_content(type, referral_bonus, referral_code)

    case type

    when 'sms'
      self.sms.gsub("\r\n", "").gsub("{{refer_bonus}}", referral_bonus.to_s).gsub("{{referral_code}}", referral_code)

    when 'email'
      self.email.gsub("\r\n", "").gsub("{{refer_bonus}}", referral_bonus.to_s).gsub("{{referral_code}}", referral_code)

    when 'facebook'
      self.facebook.gsub("\r\n", "").gsub("{{refer_bonus}}", referral_bonus.to_s).gsub("{{referral_code}}", referral_code)

    when 'twitter'
      self.twitter.gsub("\r\n", "").gsub("{{refer_bonus}}", referral_bonus.to_s).gsub("{{referral_code}}", referral_code)

    end
  end

end
