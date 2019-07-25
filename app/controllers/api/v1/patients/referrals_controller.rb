class Api::V1::Patients::ReferralsController < Api::V1::BaseApiController
  
  api :GET, '/patients/referrals/get_referral_bonus_amount', 'Get referral bonus amount'
  param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  example Api::V1::Docs::Patients::ReferralsDoc.get_referral_bonus_amount
  def get_referral_bonus_amount
    current_refer_amount = GpdqSetting.find_by_name("Refer bonus").value.to_f || 10

    render json: { success: true, refer_amount: current_refer_amount }, status: 200
  end
  
  api :GET, '/patients/referrals/get_content_for_referral', 'Get content to refer friends'
  param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  example Api::V1::Docs::Patients::ReferralsDoc.get_content_for_referral
  def get_content_for_referral
    current_refer_setting = ReferralSetting.first
    referral_bonus = GpdqSetting.find_by_name("Refer bonus").value
    referral_bonus = '%.2f' % referral_bonus
    current_referral = ReferralCode.find_or_create_by( sponsor_id: current_patient.id )
    referral_code = current_referral.voucher_code
    referral_link = new_patient_registration_url(referral_code: referral_code)

    render json: { success: true, refer_bonus: referral_bonus,
                                  sms_content: current_refer_setting.refer_content('sms', referral_bonus, referral_code),
                                  email_subject: current_refer_setting.email_subject,
                                  email_content: current_refer_setting.refer_content('email', referral_bonus, referral_code),
                                  facebook_content: current_refer_setting.refer_content('facebook', referral_bonus, referral_code),
                                  twitter_content: current_refer_setting.refer_content('twitter', referral_bonus, referral_code),
                                  refer_link: referral_link
                  }, status: 200
  end
end
