class Api::V1::Docs::Doctors::DoctorsDoc < ActionController::Base

  def self.get_infos_desc
    <<-EOS
    Updated: Tan - change available to is_working
    GET http://gpdq.co.uk/api/v1/doctors/doctors/get_infos
      PARAMS {"auth_token" => "jkDsPGkGMs7pBQoLcWLIrA"}
      ===> there are 2 case:
      - Success - Status 200:
      {
        "uid": 55,
        "email": "hang.trinh@yopmail.com",
        :auth_token => "jkDsPGkGMs7pBQoLcWLIrA",
        "avatar_url": "http://healthathomes.com/wp-content/uploads/bb_florida-ent-doctor.png",
        "fullname": "hang.trinh SW20",
        "phone_number": "258",
        "phone_landline": "",
        "latitude": 51.520445,
        "longitude": -0.066551,
        "first_name": "Hang",
        "last_name": "E1",
        "gender": null,
        "company_name": "",
        "is_working": true,
        "role": "GP",
        "status": "approved",
        "working_zones": "E1, SW1, SW20, SW5, SW7, SW8",
        "default_start_location": "E1",
        "about": "",
        "transportation": "driving"
      }
      Transportation has one of these values: driving, transit, walking. Default is driving.

      Failure: status 401
      {
        "errors": "Unauthorized"
      }
    EOS
  end
  def self.select_transportation_method_desc
    <<-EOS
    PUT http://gpdq.co.uk/api/v1/doctors/doctors/select_transportation_method
      PARAMS {"auth_token" => "jkDsPGkGMs7pBQoLcWLIrA", transportation: "driving"}
      ===> there are 2 case:
      - Success - Status 200:
      {
        "success": true,
        "appointment": {
          "uid": 191,
          "patient_id": 62,
          "doctor_id": 55,
          "patient_full_name": "Hang Trinh EC1",
          "start_time": "August 19, at 07:13AM",
          "short_start_time": "07:13AM",
          "estimated_time": 6,
          "status": "on_way",
          "lat": 51.521223,
          "lng": -0.0433301,
          "address": "22 Ernest St, London E1 4LS, UK",
          "patient_phone": '12345678',
          "start_in_second": 999,
          "transport": 'transit'
        }
      }
      
      Failure: status 400
      {
        "success": false
      }
    EOS
  end

  def self.update_location
    <<-EOS
    Author: Thanh
    Updated: Tan - change available to is_working; update doctor's address
    PUT http://gpdq.co.uk/api/v1/doctors/doctors/update_location
      PARAMS { "auth_token" => "jkDsPGkGMs7pBQoLcWLIrA", "lat" => "51.520445", "lng" => "-0.066551", "address" => "123 E1 London UK" }
      ===> there are 2 case:
      - Success - Status 200:
      {
        "doctor": {
          "uid": 55,
          "email": "hang.trinh@yopmail.com",
          "auth_token": "jkDsPGkGMs7pBQoLcWLIrA",
          "avatar_url": "http://healthathomes.com/wp-content/uploads/bb_florida-ent-doctor.png",
          "fullname": "hang.trinh SW20",
          "phone_number": "258",
          "phone_landline": "",
          "latitude": 51.520445,
          "longitude": -0.066551,
          "first_name": "Hang",
          "last_name": "E1",
          "gender": null,
          "company_name": "",
          "is_working": true,
          "role": "GP",
          "status": "approved",
          "working_zones": "E1, SW1, SW20, SW5, SW7, SW8",
          "default_start_location": "E1",
          "about": ""
        }
      }
      
      - Fail - status 422:
      {
        "errors": "Error message"
      }
    EOS
  end

  def self.find_doctors_around
    <<-EOS
    Author: Thanh
    Updated: Tan - change available to is_working
    GET http://gpdq.co.uk/api/v1/doctors/doctors/find_doctors_around
      PARAMS { "auth_token" => "jkDsPGkGMs7pBQoLcWLIrA" }
      ===> there are 2 cases:
      - List doctors around - Status 200:
      {
        "doctors": [
          {
            "uid": 55,
            "email": "hang.trinh@yopmail.com",
            "auth_token": "wH206knv__c4HgcFs1oiFw",
            "avatar_url": "http://healthathomes.com/wp-content/uploads/bb_florida-ent-doctor.png",
            "fullname": "hang.trinh SW20",
            "phone_number": "258",
            "phone_landline": "",
            "latitude": 51.520445,
            "longitude": -0.066551,
            "first_name": "Hang",
            "last_name": "E1",
            "gender": null,
            "company_name": "",
            "is_working": true,
            "role": "GP",
            "status": "approved",
            "working_zones": "E1, SW1, SW20, SW5, SW7, SW8",
            "default_start_location": "E1",
            "about": "",
            "transportation": "driving"
          }
        ]
      }
      
      - List doctors around empty or doctor does not have latitude and longitude - status 200:
      {
        "doctors": []
      }
    EOS
  end

  def self.update_working_status
    <<-EOS
    Author: Tan
    PUT http://gpdq.co.uk/api/v1/doctors/doctors/update_working_status
      PARAMS { "auth_token" => "jkDsPGkGMs7pBQoLcWLIrA", "working_status": "on"}
      note: working_status need to be 'on' or 'off' only, others will fail

      ===> There are a lot of cases:

      - Success - Status 200:
      {
        "success": true,
        "is_working": true
      }

      - Failed( in case unauthorized ) - Status 401:
      {
        "message": "Unauthorized"
      }

      - Fail( working_status params is blank or not 'on'/'off' ) - Status 422:
      {
        "success": false,
        "errors": "Unavailable status",
        "is_working": true
      }

      - Fail( set off duty when doctor gets an 'on way' appointment ) - Status 422:
      {
        "success": false,
        "errors": "This appointment is confirmed as 'on way', you need to return it before you stop working!",
        "is_working": true
      }

      - Fail( set off duty when doctor gets an 'on process' appointment ) - Status 422:
      {
        "success": false,
        "errors": "This appointment is confirmed as 'on process', you need to finish it before you stop working!",
        "is_working": true
      }

      - Fail( errors when updating doctor available attribute, error messages may be various ) - Status 422:
      {
        "success": false,
        "errors": "Error Message",
        "is_working": true
      }
    EOS
  end

  def self.update_device_token
    <<-EOS
    Author: Thanh
    PUT http://gpdq.co.uk/api/v1/doctors/doctors/update_device_token
      PARAMS {"auth_token" => "jkDsPGkGMs7pBQoLcWLIrA", "device_token" => "device_token", "platform" => "ios"}
      platform values: "ios" or "android"
      There are 2 cases:

      - Success - 200:
      {
        "doctor": {
          "uid": 62,
          "device_token": "device_token",
          "platform": "ios"
        }
      }

      - Fail - 422:
      {
        "message": "Missing parameters",
        "errors": "device_token can't be blank",
        "success": false
      }

      - Fail - 422:
      {
        "errors": "Platform abc is not a valid platform"
      }
    EOS
  end
end