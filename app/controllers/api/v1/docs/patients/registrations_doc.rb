class Api::V1::Docs::Patients::RegistrationsDoc <  ActionController::Base

  def_param_group :signup_fb do
    param "patient[fb_id]", String, desc: "facebook id get from fb", :required => true
    param "patient[fb_token]", String, desc: "fb token", :required => true
    param "patient[fullname]", String, desc: "full name", :required => true
    param "patient[email]", String, desc: "email", :required => true
    param "patient[password]", String, desc: "password", :required => true
    param "patient[phone_number]", String, desc: "phone name", :required => true
    param "patient[terms_of_service]", String, desc: "Accept Term of service, value should: true", required: true
    param "patient[over_18]", String, desc: "App just for user is over 18, value should: true", required: true
    param "patient[lat]", Float, desc: "Patient's latitude"
    param "patient[lng]", Float, desc: "Patient's longitude"
    param "patient[device_token]", String, desc: "Patient's device_token"
    param "patient[platform]", String, desc: "Patient's device platform, value = ios/android"
  end

  def_param_group :sign_up do
    param "patient[fullname]", String, desc: "Patient's fullname", :required => true
    param "patient[email]", String, desc: "Patient's email", :required => true
    param "patient[phone_number]", String, desc: "Patient's phone number", :required => true
    param "patient[password]", String, desc: "Patient's password", :required => true
    param "patient[lat]", Float, desc: "Patient's latitude"
    param "patient[lng]", Float, desc: "Patient's longitude"
    param "patient[device_token]", String, desc: "Patient's device_token"
    param "patient[platform]", String, desc: "Patient's device platform, value = ios/android"
  end

  def self.sign_up_with_fb_desc
    <<-EOS
    Author: Thuy
    Updated: Tan - Merge the register info to an existed account with the same fb_id or email
    POST 'http://gpdq.co.uk/api/v1/patients/registrations/sign_up_with_fb
      PARAMS {"patient"=>{"fb_id": "1234123412323", "fullname": "John Smith", "email": "example@example.com",
              "phone_number": "1234", "password": "password", "terms_of_service": "1", "over_18": "1", "device_token": "1aswddeafg", "platform": "android"}}
      ===> Here are the cases:

      - Status 200 in case create or update patient successfully:
      {
        "id": 12,
        "fullname": "thuy",
        "email": "thuy3@gmail.com",
        "password", "123456",
        "phone_number": "12341234222",
        "fb_id": "1234123412323",
        "fb_token": null,
        "auth_token": "FlFep-EEzi33UzFIfN3kEQ"
      }

      - Status 422 in case getting error when creating or updating patient
      {
        "errors": "Email can't be blank",
        "message": "Sign up unsuccessfully!"
      }

      - Status 422 in case facebook account existed:
      {
        "errors": "It looks like example@example.com belongs to an existing account. Please sign in with Facebook"
      }

      - Status 422 in case missing parameters:
      {
        "errors": "password can't be blank"
        "message": "Missing parameters"
      }
    EOS
  end

  def self.sign_up
    <<-EOS
      POST 'http://gpdq.co.uk/api/v1/patients/registrations/sign_up
      PARAMS {"patient"=>{"fullname": "John Smith", "email": "example@example.com",
              "phone_number": "1234", "password": "password", "terms_of_service": "true", "over_18": "true", "device_token": "1aswddeafg", "platform": "ios"}}
      ===> There are 3 cases:

      - Status 201 in case create patient successfully:
      {
        "patient_info": {
          "uid": 25,
          "fullname": "John Smith",
          "email": "example@example.com",
          "phone_number": "1234",
          "auth_token": "fWX_531kU_LD8aJZFnFJbw"
        },
        "success": true
      }

      - Status 400 incase create patient unsuccessfully:
      {
        "success": false,
        "errors": "Email is invalid"
      }

      - Status 422 incase missing parameters:
      {
        "message": "Missing parameters",
        "errors": "password can't be blank"
      }
    EOS
  end

end