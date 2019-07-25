class Api::V1::Docs::Patients::ReferralsDoc <  ActionController::Base

  def self.get_referral_bonus_amount
    <<-EOS
    Author: Tan
    GET http://gpdq.co.uk/api/v1/patients/referrals/get_referral_bonus_amount
      PARAMS  { "auth_token": "jkDsPGkGMs7pBQoLcWLIrA" }
      ===> There are 2 cases:

      - Success - Status 200: 
      {
        "success": true,
        "refer_amount": 11.25
      }

      - Failed( in case unauthorized ) - Status 401:
      {
        "message": "Unauthorized"
      }
    EOS
  end

  def self.get_content_for_referral
    <<-EOS
    Author: Tan
    GET http://gpdq.co.uk/api/v1/patients/referrals/get_content_for_referral
      PARAMS  { "auth_token": "jkDsPGkGMs7pBQoLcWLIrA" }
      ===> There are 2 cases:

      - Success - Status 200: 
      {
        "success": true,
        "refer_bonus": 10,
        "email_subject": "Referral email from GPDQ",
        "sms_content": "Get 10 off your first appointment by using my referral code: m16et6GI",
        "email_content": "Get 10 off your first appointment by using my referral code: m16et6GI",
        "facebook_content": "Get 10 off your first appointment by using my referral code: m16et6GI",
        "twitter_content": "Get 10 off your first appointment by using my referral code: m16et6GI",
        "refer_link": "http://gpdq.co.uk/patients/sign_up?referral_code=m16et6GI"
      }

      - Failed( in case unauthorized ) - Status 401:
      {
        "message": "Unauthorized"
      }
    EOS
  end
  

end