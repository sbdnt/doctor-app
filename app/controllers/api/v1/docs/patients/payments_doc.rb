class Api::V1::Docs::Patients::PaymentsDoc <  ActionController::Base
  def_param_group :paypal_payment_params do
    # param "paypal_payment[paypal_email]", String, desc: "Patient's paypal email", required: true
    # param "save_for_furture", String, desc: "Status save for future: yes or no"
    # param "paypal_payment[password]", String, desc: "Patient's password", required: true
    param "paypal_payment[authorization_code]", String, desc: "Patient's payment token", required: true
  end

  def_param_group :credit_payment_params do
    param "save_for_furture", String, desc: "Status save for future: yes or no"
    param "credit_payment[cc_type]", String, desc: "Credit card type, should be: ['visa', 'mastercard']", required: true
    param "credit_payment[cc_num]", String, desc: "Credit card number", required: true
    param "credit_payment[expiry]", String, desc: "Expired date: ex: 12/2016", required: true
    param "credit_payment[cvc]", String, desc: "Credit card's cvc" , required: true
    param "credit_payment[lat_bill_address]", Float, "Billing address's latitude (Decimal precision 12, scale 8)", required: true
    param "credit_payment[lng_bill_address]", Float, "Billing address's longitude (Decimal precision 12, scale 8)", required: true
    param "credit_payment[bill_address]", String, "Billing address", required: true
  end

  def self.create_paypal_payment_decs
    <<-EOS
    POST 'http://gpdq.co.uk/api/v1/patients/payments/create_paypal_payment'
      PARAMS { "auth_token" => "wMEvSvS9zBa6-Ii6RWHpqg", "paypal_payment" => {"authorization_code"=>"awq23455"}}
      ===> There are 4 cases:

      - Status 201 in case create new paypal payment successfully:
      {
        "success": true,
        "message": "Your paypal account was saved successfully!",
        "paypal_payment": [
          {
            "uid": 23,
            "paypal_email": "paypal@gmail.com",
            "paymentable_type": "PatientPaypalPayment"
          }
        ]
      }

      - Status 200 in case update exist paypal payments:
      {
        "success": true,
        "message": "Your paypal account was updated successfully!",
        "paypal_payment": [
          {
          "uid": 6,
          "paypal_email": "paypal@gmail.com",
          "paymentable_type": "PatientPaypalPayment"
          }
        ]
      }

      - Status 422 incase authorization code invalid:
      {
        "success": false,
        "errors": "Invalid token"
      }

      - Status 422 incase params is missing:
      {
        "message": "Missing parameters",
        "errors": "authorization_code can't be blank"
      }


    EOS
  end

  def self.create_credit_payment_desc
    <<-EOS
    Updated: Thanh - update docs and credit card data 
    POST http://gpdq.co.uk/api/v1/patients/payments/create_credit_payment

    PARAMS { "auth_token"=>"wMEvSvS9zBa6-Ii6RWHpqg", "credit_payment"=>{"cc_num"=>"4929027334865501", "expiry"=>"30/08/2016", "cvc"=>"456", "cc_type"=>"visa",
     "lat_bill_address"=>"10.8156995", "lng_bill_address"=>"106.688687", "bill_address"=>"466 Lê Quang Định, phường 11, Hồ Chí Minh, Vietnam"}, "save_for_furture"=>"yes"} 
    ===> There are 6 cases:

      - Success - 201 (save_for_furture: 'yes'):
      {
        "success": true,
        "message": "Your credit account was saved successfully!",
        "credit_payment": [
                            {
                              "uid": 96,
                              "cc_num": "5168xxxxxxxx6077",
                              "cc_num_full": "5168625238756077",
                              "cc_type": "mastercard",
                              "paymentable_type": "PatientCreditPayment",
                              "lat_bill_address": "10.8064534",
                              "lng_bill_address": "106.696984",
                              "bill_address": "33 Lê Quang Định, phường 14, Ho Chi Minh, Vietnam"
                            },
                            {
                              "uid": 97,
                              "cc_num": "4111xxxxxxxx1111",
                              "cc_num_full": "4111111111111111",
                              "cc_type": "visa",
                              "paymentable_type": "PatientCreditPayment",
                              "lat_bill_address": "10.8064534",
                              "lng_bill_address": "106.696984",
                              "bill_address": "33 Lê Quang Định, phường 14, Ho Chi Minh, Vietnam"
                            }
                          ]
      }

      - Success - 201: new card does not link to patient and not returned in credit payment list:
      {
        "success": true,
        "message": "Your credit card info was not saved!",
        "credit_payment": [
                            {
                              "uid": 96,
                              "cc_num": "5168xxxxxxxx6077",
                              "cc_num_full": "5168625238756077",
                              "cc_type": "mastercard",
                              "paymentable_type": "PatientCreditPayment",
                              "lat_bill_address": "10.8064534",
                              "lng_bill_address": "106.696984",
                              "bill_address": "33 Lê Quang Định, phường 14, Ho Chi Minh, Vietnam"
                            },
                            {
                              "uid": 97,
                              "cc_num": "4111xxxxxxxx1111",
                              "cc_num_full": "4111111111111111",
                              "cc_type": "visa",
                              "paymentable_type": "PatientCreditPayment",
                              "lat_bill_address": "10.8064534",
                              "lng_bill_address": "106.696984",
                              "bill_address": "33 Lê Quang Định, phường 14, Ho Chi Minh, Vietnam"
                            }
                          ]
      }

      - Credit card number is not correct format - 422:
      {
        "success": false,
        "errors": "Credit card number is invalid."
      }

      - Expire date is not valid - 422:
      {
        "success": false,
        "errors": "Expire date must be a valid date."
      }

      - Expire date is a past date - 422:
      {
        "success": false,
        "errors": "Expire date must be a date in future."
      } 

      - Missing params - 422:
      {
        "message": "Missing parameters",
        "errors": "cvc can't be blank"
      }

    EOS
  end

  def self.billing_addresses_desc
    <<-EOS
    GET 'http://gpdq.co.uk/api/v1/patients/payments/billing_addresses
      PARAMS {}

      - Status 200 in get locations successfully:
      - empty
      []

      - have locations
      [
        {
          "uid": 1,
          "address": "Ho Chi Minh, Vietnam",
          "latitude": 10.8230989,
          "longitude": 106.6296638
        }
      ]
    EOS
  end

end