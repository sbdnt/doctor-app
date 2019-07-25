class Api::V1::Docs::Patients::SessionsDoc <  ActionController::Base

  def_param_group :base_group do
    param :auth_token, String, desc: "Authentication token", required: true
  end

  def_param_group :login_fb do
    param :fb_id, String, desc: "Patient's fb_id", :required => true
    param :fb_token, String, desc: "Patient's fb_token", :required => true
    param :lat, Float, desc: "Patient's latitude"
    param :lng, Float, desc: "Patient's longitude"
    param :device_token, String, desc: "Patient's device_token"
    param :platform, String, desc: "Patient's device platform"
  end

  def_param_group :login_normal do
    param "patient[email]", String, desc: "Patient's email", :required => true
    param "patient[password]", String, desc: "Patient's password", :required => true
    param "patient[lat]", Float, desc: "Patient's latitude"
    param "patient[lng]", Float, desc: "Patient's longitude"
    param "patient[device_token]", String, desc: "Patient's device_token"
    param "patient[platform]", String, desc: "Patient's device platform, value = ios/android"
  end

  def self.login_with_fb_desc
    <<-EOS
      Updated: Thanh - updated api docs and status codes
      POST http://gpdq.co.uk/api/v1/patients/sessions/login_with_fb
      PARAMS  {"fb_id": "534654623465t436", "fb_token": "42353453245345345435", "device_token": "1hhwsafdq", "platform": "ios"}
      ===> There are 4 cases:

      - Success - 200:
      {
        "uid": 11,
        "fullname": null,
        "email": "thuynt04@gmail.com",
        "phone_number": "1234567895",
        "fb_id": "1144755182206393",
        "fb_token": null,
        "auth_token": "tfACLMoecVM27jjnJ7hHvQ"
      }

      - Account does not exists - 422:
      {
        message: "You don't have an existing account, please access to the register section"
      }

      - Invalid facebook token - 400:
      {
        message: "Invalid facebook token"
      }

      - Missing Facebook id - 400:
      {
        message: "Missing Facebook id",
        errors: "fb_id can't be blank"
      }

    EOS
  end

  def self.create
    <<-EOS
      POST 'http://gpdq.co.uk/api/v1/patients/sessions
      PARAMS {"patient"=>{"email": "example@example.com", "password": "password", "device_token": "1hhwsafdq", "platform": "android"}}
      ===> There are 4 cases:

      - Status 200 in case patient logged in successfully:
      {
        "patient_info": {
          "uid": 15,
          "fullname": null,
          "email": "example@example.com",
          "phone_number": "0908",
          "auth_token": "2JZqxJaS4Gzl82tkzU4crQ"
        },
        "success": true
      }

      - Status 401 incase patient's email does not exist:
      {
        "success": false,
        "errors": "Email does not exist"
      }

      - Status 401 incase patient's password was incorrect:
      {
        "success": false,
        "errors": "Password was incorrect"
      }

      - Status 422 incase missing parameters:
      {
        "message": "Missing parameters",
        "errors": "email can't be blank"
      }

    EOS
  end

end