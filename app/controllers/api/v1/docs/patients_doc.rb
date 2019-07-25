class Api::V1::Docs::PatientsDoc <  ActionController::Base
  # def_param_group :default do
  #   param :default_week, Integer, desc: "true: load default for week; false: load default for day."
  # end

  def_param_group :sign_up do
    param :fullname, String, desc: "Patient's fullname"
    param :email, String, desc: "Patient's email"
    param :phone_number, String, desc: "Patient's phone number"
    param :password, String, desc: "Patient's password"
  end

  def_param_group :patient_profile do
    param :auth_token, String, desc: "Authentication token", required: true

    param 'patient[fullname]', String, desc: "Patient's fullname", required: true
    param 'patient[email]', String, desc: "Patient's email", required: true
    param 'patient[phone_number]', String, desc: "Patient's phone number", required: true

    param 'credit_payment[cc_payment_id]', Integer, desc: "Credit payment id", required: true
    param 'credit_payment[cc_num]', String, desc: "Credit card number", required: true
    param 'credit_payment[expiry]', String, desc: "Credit card expiration", required: true
    param 'credit_payment[cvc]', Integer, desc: "Credit cvc", required: true
    param 'credit_payment[cc_type]', String, desc: "Credit card type", required: true

    param 'paypal_payment[payment_id]', Integer, desc: "Paypal payment id", required: true
    param 'paypal_payment[paypal_email]', String, desc: "Paypal email", required: true
    param 'paypal_payment[password]', String, desc: "Paypal password", required: true
  end

  # def_param_group :apply_default do
  #   param :auth_token, String, desc: "Authenticate of agency or doctor."
  #   param :start_time, String, desc: "String 2015-06-29 08:00"
  #   param :end_time, String, desc: "Datetime 2015-06-30 08:00"
  #   param :selected_days, Array, desc: "Array for selected days"
  # end

  # def_param_group :event do
  #   param :auth_token, String, desc: "Authenticate of agency or doctor."
  #   param "agency_period[start_at]", String, desc: "String 2015-06-29 08:00"
  #   param "agency_period[end_at]", String, desc: "Datetime 2015-06-30 08:00"
  #   param "agency_period[doctor_id]", Integer, desc: "Id of doctor"
  #   param "agency_period[custom_status]", Integer, desc: "Edit event for doctor"
  #   param "agency_period[default_common_status]", Integer, desc: "Edit event for default schedule"
  #   param "agency_period[is_default_week]", Integer, desc: "Edit for default week or default day"
  # end

  # def self.apply_default_schedule_desc
  #   <<-EOS
  #     {"success": true}
  #   EOS
  # end

  def self.index
    <<-EOS
      Updated: Thanh - update docs and credit card data
      GET http://gpdq.co.uk/api/v1/patients/patients'
      PARAMS {"auth_token": "wMEvSvS9zBa6-Ii6RWHpqg"}
      ===> There are 2 cases:

      - Success - 200:
      {
        "success": true,
        "patient_info": {
          "uid": 62,
          "fullname": "Hang Trinh EC1",
          "email": "hang.ec1@yopmail.com",
          "phone_number": "12345678",
          "auth_token": "Is2392__L-SfxRt5VwMp6Q"
        },
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
        ],
        "paypal_payment": [
          {
            "uid": 24,
            "paypal_email": "paypal1@gmail.com",
            "paymentable_type": "PatientPaypalPayment"
          }
        ]
      }

      - Unauthorized - 401:
      {
        "message": "Unauthorized"
      }

    EOS
  end

  def self.update_profile
    <<-EOS
      PUT 'http://gpdq.co.uk/api/v1/patients/patients/update_profile'

      #Params for update patient's base infos
      PARAMS {"auth_token": "wMEvSvS9zBa6-Ii6RWHpqg", "patient"=>{"fullname": "John Smith", "email": "example@example.com", "phone_number": "1234"}}

      ===> There are 4 cases:

      - Status 200 in case update patient's info successfully:
      {
        "success": true
      }

      - Status 401 incase unauthorized:
      {
        "message": "Unauthorized"
      }

      - Status 422 incase missing parameter:
      {
        "success": false,
        "errors": "Missing parameters"
      }

      - Status 500 incase patient's profile was updated unsuccessfully:
      {
        "success": false,
        "errors": "Email is invalid"
      }

      #Params for update patient's credit infos
      PARAMS {"auth_token": "wMEvSvS9zBa6-Ii6RWHpqg", "credit_payment"=>{"cc_payment_id": "13", "cc_num": "4111 1111 1111 1111", "expiry": "11/2018", "cvc": "111", "cc_type": "visa"}}
      "cc_type" should be in ['visa', 'mastercard']

      ===> There are 5 cases:

      - Status 200 in case update patient's credit info successfully:
      {
        "success": true
      }

      - Status 401 incase unauthorized:
      {
        "message": "Unauthorized"
      }

      - Status 422 incase missing parameter:
      {
        "message": "Missing parameters",
        "errors": {
          "cc_type": [
            "can't be blank"
          ]
        }
      }

      - Status 422 incase params cc_type is not valid:
      {
        "success": false,
        "errors": "abc is not a valid cc_type"
      }

      - Status 500 incase patient's profile was updated unsuccessfully:
      {
        "success": false,
        "message": "Patient's profile was updated unsuccessfully",
        "errors": {
          "email": [
            "is invalid"
          ]
        }
      }

      #Params for add new patient's credit infos
      PARAMS {"auth_token": "wMEvSvS9zBa6-Ii6RWHpqg", "credit_payment"=>{"cc_num": "4111 1111 1111 1111", "expiry": "11/2018", "cvc": "111", "cc_type": "visa"}}
      "cc_type" should be in ['visa', 'mastercard']

      ===> There are 3 cases:

      - Success:
      {
        "success": true
      }
      Status 201 Created

      - Fail:
      {
        "success": false
        "errors": "Message error"
      }
      Status 422 Unprocessable Entity

      - Fail:
      {
        "success": false
        "errors": "abc is not a valid cc_type"
      }
      Status 422 Unprocessable Entity


      #Params for update patient's paypal infos
      PARAMS {"auth_token": "wMEvSvS9zBa6-Ii6RWHpqg", "paypal_payment"=>{"payment_id": "13", "paypal_email": "paypal@paypal.com", "password": "password"}}

      ===> There are 5 cases:

      - Status 200 in case update patient's credit info successfully:
      {
        "success": true,
        "message": "Patient's paypal info was updated successfully"
      }

      - Status 401 incase unauthorized:
      {
        "message": "Unauthorized"
      }

      - Status 422 incase missing parameter:
      {
        "message": "Missing parameters",
        "errors": {
          "password": [
            "can't be blank"
          ]
        }
      }

      - Status 422 incase params cc_type is not valid:
      {
        "success": false,
        "errors": "abc is not a valid cc_type"
      }

      - Status 500 incase patient's profile was updated unsuccessfully:
      {
        "success": false,
        "message": "Patient's profile was updated unsuccessfully",
        "errors": {
          "paypal_email": [
            "This is not a valid email format"
          ]
        }
      }
    EOS
  end

  def self.view_doctor_profile_desc
    <<-EOS
    PUT 'http://gpdq.co.uk/api/v1/patients/patients/1/view_doctor_profile
      PARAMS {"auth_token" => "fadfasdf"}
      - Status 200:
      {
          "id": 2,
          "about": null,
          "avatar_url": "http://localhost:3000/uploads/doctor/avatar/2/bong_bay.jpg",
          "fullname": "1"
      }
    EOS
  end

  def self.total_credits_desc
    <<-EOS
      Author: Tuan
      Updated: Tan - update docs
      GET 'http://gpdq.co.uk/api/v1/patients/patients/total_credits
        PARAMS {"auth_token" => "jkDsPGkGMs7pBQoLcWLIrA"}

        ===> There are 2 cases:
        - Status 401 incase unauthorized:
        {
          "message": "Unauthorized"
        }

        - Status 200:
        {
          "uid": 4,
          "fullname": "Hang 4",
          "email": "hang.4@yopmail.com",
          "total_credits": 0
        }
    EOS
  end
  def self.update_credits_desc
    <<-EOS
    POST 'http://gpdq.co.uk/api/v1/patients/patients/11/update_credits
      PARAMS {"auth_token" => "jkDsPGkGMs7pBQoLcWLIrA", "11"}
      - Status 200:
      {
          "id": 2,
          "success": true
      }
    EOS
  end


  def self.update_paypal_access_token_desc
    <<-EOS
      Author: TuanBui
      Updated: TuanBui
      POST 'http://gpdq.co.uk/api/v1/patients/patients/update_paypal_access_token
      PARAMS {"auth_token" => "jkDsPGkGMs7pBQoLcWLIrA", "paypal_access_token" => ""WfXdnxmyJtdF4q59ofxuQuAAk6eEV-Njm6puht3Nk3w" "}
      - Status 401 incase unauthorized:
      {
        "message": "Unauthorized"
      }
      - Status 422 incase params paypal_access_token is blank:
      {
        "success": false,
        "errors": "paypal_access_token is not blank"
      }

      - Status 200 in case update patient's paypal_access_token successfully:
      {
        "id": 11,
        "success": true,
        "message": "Patient's paypal info was updated successfully"
      }
      - Status 500 incase patient's paypal_access_token was updated unsuccessfully:
      {
          "id": 11,
          "success": false
          "message": 'Patient has updated the paypal access_token unsuccessfully.'
      }
    EOS
  end

  def self.patient_invoice
    <<-EOS
    PUT 'http://gpdq.co.uk/api/v1/patients/appointments/patient_invoice
      PARAMS {"auth_token" => "jkDsPGkGMs7pBQoLcWLIrA", "appointment_id" => "12"}
      - Status 200:
      {
        "total_amount": 3090,
        "base_fare": 1710,
        "extra_item_list": [
          {
            "category_id": 1,
            "category_name": "Drug",
            "total": 900
          },
          {
            "category_id": 2,
            "category_name": "Extra",
            "total": 480
          }
        ],
        "created_at": "Jul 30, 2015 10:29:51AM"
      }
    EOS
  end

  def self.track_doctor_desc
    <<-EOS
    GET 'http://gpdq.co.uk/api/v1/patients/:doctor_id/track_doctor
      PARAMS {"auth_token" => "jkDsPGkGMs7pBQoLcWLIrA"}
      - Status 200:
      {
        "id": 21,
        "latitude": 51.5216824,
        "longitude": -0.0952118,
        "avatar_url": "http://localhost:3000",
        "fullname": "Jonh Smith",
        "eta": 4
      }
    EOS
  end

  def self.update_device_token
    <<-EOS
    Author: Thanh
    PUT http://gpdq.co.uk/api/v1/patients/patients/update_device_token
      PARAMS {"auth_token" => "jkDsPGkGMs7pBQoLcWLIrA", "device_token" => "device_token", "platform" => "ios"}
      platform values: "ios" or "android"
      There are 2 cases:

      - Success - 200:
      {
        "patient": {
          "uid": 63,
          "device_token": "device_token",
          "platform": "ios"
        }
      }

      - Fail - 422:
      {
        "message": "Missing parameters",
        "errors": "device_token can't be blank"
      }

      - Fail - 422:
      {
        "errors": "Platform abc is not a valid platform"
      }
    EOS
  end
end