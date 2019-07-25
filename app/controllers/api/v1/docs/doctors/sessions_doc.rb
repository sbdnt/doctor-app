class Api::V1::Docs::Doctors::SessionsDoc <  ActionController::Base

  def_param_group :base_group do
    param :auth_token, String, desc: "Doctor Authentication token", required: true
  end

  def self.create
    <<-EOS
      Author: Thanh
      Updated: Tan - change available to is_working
      POST http://gpdq.co.uk/api/v1/doctors/sessions
      PARAMS { "email": "example@example.com", "password": "password", "device_token": "1hhwsafdq", "platform": "ios"} 
      ===> There are 5 cases:

      - Success - Status 200:
      {
        "success": true,
        "doctor": {
          "uid": 55,
          "email": "hang.trinh@yopmail.com",
          "auth_token": "FQevafXeinmWsyndQzgQjQ",
          "avatar_url": "http://healthathomes.com/wp-content/uploads/bb_florida-ent-doctor.png",
          "fullname": "hang.trinh SW20",
          "phone_number": "258",
          "phone_landline": "",
          "latitude": 51.528578,
          "longitude": -0.304403,
          "first_name": "SW7",
          "last_name": "SW5 SW1 SW8",
          "gender": null,
          "company_name": "",
          "is_working": true,
          "role": "GP",
          "status": "approved",
          "working_zones": "SW1, SW20, SW5, SW7, SW8",
          "default_start_location": "SW20",
          "about": "",
          "transportation": "driving"
        }
      }
      Transportation has one of these values: driving, transit, walking. Default is driving.

      - Fail - Status 422:
      {
        "success": false,
        "errors": "Your account has been rejected, please contact admin for more information"
      }

      - Fail - Status 422:
      {
        "success": false,
        "errors": "Your account is pending, please contact admin for more information"
      }

      - Fail - Status 422:
      {
        "success": false,
        "errors": "Email does not exist"
      }

      - Fail - Status 422:
      {
        "success": false,
        "errors": "Password was incorrect"
      }

      - Fail - Status 422:
      {
        "success": false,
        "errors": "Missing email"
      }

      - Fail - Status 422:
      {
        "success": false,
        "errors": "Missing password"
      }

    EOS
  end

end