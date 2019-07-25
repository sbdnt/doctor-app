class Api::V1::Docs::Patients::MapsDoc <  ActionController::Base

  def_param_group :address_param do
    param :address, String, desc: "Patient's address", :required => true
    param :latitude, Float, desc: "Patient's latitude address", :required => true
    param :longitude, Float, desc: "Patient's longitude address", :required => true
    param :address_type, String, desc: "Address's type"
    param :is_bill_address, String, desc: "Address is used for billing?(true/false)", required: true
    param :location_id, Integer, desc: "Location's id to edit"
  end

  def_param_group :get_billing do
    param :type, String, desc: "Type to get last two billing address or saved address(billing/saved_address)", :required => true
  end

  def_param_group :doctor_around_param do
    param :lat, Float, desc: "Patient's latitude", required: true
    param :lng, Float, desc: "Patient's longitude", required: true
    param :address, String, desc: "Patient's address"
    param :range, Integer, desc: "range: eta from doctor to center zone"
  end

  def_param_group :out_covarage_area_param do
    param :name, String, desc: "Patient's name", required: true
    param :email, String, desc: "Patient's email", required: true
    param :post_code, String, desc: "Patient's post code"
  end

  def self.save_address_desc
    <<-EOS
    PUT 'http://gpdq.co.uk/api/v1/patients/maps/save_address
      => Case update patient's saved addresses
        PARAMS {auth_token: "gHtdHHx6gEfWL7c6ckc5Vg", "location_id" => 1, "address" => "Brady Street Cemetery, London, UK", "latitude" => "10.811934910947109", "longitude" => "106.68986320495605", "address_type" => "work", "is_bill_address" => "true"}
        There are 2 cases:

            - Status 200 in case address was updated successfully:
            {
              "success": true,
              "location": {
                "uid": 83,
                "address": "London",
                "latitude": 10,
                "longitude": 10
              }
            }

            - Status 422 in case missing parameters:
            {
              "message": "Missing parameters",
              "errors": "address can't be blank"
            }

      => Case create patient's address
        PARAMS {auth_token: "gHtdHHx6gEfWL7c6ckc5Vg", "address" => "Brady Street Cemetery, London, UK", "latitude" => "10.811934910947109", "longitude" => "106.68986320495605", "address_type" => "home", "is_bill_address" => "true"}
        There are 2 cases:

          - Status 200 in case address was saved successfully:
          {
            "success": true,
            "location": {
              "uid": 83,
              "address": "London",
              "latitude": 10,
              "longitude": 10
            }
          }

          - Status 422 in case missing parameters:
          {
            "message": "Missing parameters",
            "errors": "address can't be blank"
          }

    EOS
  end

  def self.save_billing_address
    <<-EOS
    PUT 'http://gpdq.co.uk/api/v1/patients/maps/save_billing_address
      PARAMS {auth_token: "gHtdHHx6gEfWL7c6ckc5Vg", "address" => "Brady Street Cemetery, London, UK", "latitude" => "10.811934910947109", "longitude" => "106.68986320495605"}
      ===> There are 2 cases:

      - Status 200 in case save address successfully:
      {
        "success": true,
        "location": {
          "uid": 83,
          "address": "London",
          "latitude": 10,
          "longitude": 10
        }
      }

      - Status 422 in case missing parameters:
      {
        "message": "Missing parameters",
        "errors": "address can't be blank"
      }

    EOS
  end

  def self.find_doctor_around_old_desc
    <<-EOS
    GET 'http://gpdq.co.uk/api/v1/patients/maps/find_doctor_around
      PARAMS {"lat" => 51.522074, "lng": -0.060478, range: 60, auth_token: "gHtdHHx6gEfWL7c6ckc5Vg", "address" => "123 E1 London UK"}

      - Status 200: return list of doctors successfully
      {
        "doctor_infos": [
            {
                "uid": 17,
                "email": "new@gmail.com",
                "fullname": "test",
                "phone_number": "",
                "phone_landline": "",
                "latitude": 51.520111,
                "longitude": -0.066679,
                "first_name": null,
                "last_name": null
            }
        ],
        "min_eta": 0
      }

      - Status 424 if don't have any doctors the same with patient's zone and range:
      {
        "success": false,
        "errors": "Oops! We are currently experiencing high demand. Please contact GPDQ to book your appointment for a later time"
      }

      - Status 422 if patient selected a location that is outside of GPDQ's coverage area:
      {
        "success": false,
        "errors": "You've requested an appointment in an area not yet covered by GPDQ, however we are continually expanding and hope to cover your area soon. Please click here to register."
      }

    EOS
  end

  def self.find_doctor_around_desc
    <<-EOS
    PUT 'http://gpdq.co.uk/api/v1/patients/maps/find_doctor_around
      PARAMS {"lat" => 51.522074, "lng": -0.060478, range: 60, auth_token: "gHtdHHx6gEfWL7c6ckc5Vg", "address" => "123 E1 London UK"}

      - Status 200: return list of doctors successfully
      {
        "doctor_infos": [
            {
                "uid": 17,
                "email": "new@gmail.com",
                "fullname": "test",
                "phone_number": "",
                "phone_landline": "",
                "latitude": 51.520111,
                "longitude": -0.066679,
                "first_name": null,
                "last_name": null
            }
        ],
        "min_eta": 0
      }

      - Status 422 if don't have any doctors the same with patient's zone and range:
      {
        "success": false,
        "errors": "Oops! We are currently experiencing high demand. Please contact GPDQ to book your appointment for a later time"
      }

      - Status 422 if patient selected a location that is outside of GPDQ's coverage area:
      {
        "success": false,
        "errors": "You've requested an appointment in an area not yet covered by GPDQ, however we are continually expanding and hope to cover your area soon. Please click here to register."
      }

    EOS
  end

  def self.get_last_addresses
    <<-EOS
    GET 'http://gpdq.co.uk/api/v1/patients/maps/get_last_two_addresses
      PARAMS {"auth_token" => "E_NowFeAwfMDtUlq0aKshg", "type" => "billing"}

      ==> Get last two saved addresses of patients

      - Status 200: in case get address successfully
      {
        "success": true,
        "location": [
          {
            "uid": 84,
            "address": "105A Nguyễn Thượng Hiền, phường 5, Bình Thạnh, Hồ Chí Minh, Vietnam",
            "latitude": 10.8107124563908,
            "longitude": 106.684284210205,
            "address_type": "home"
          },
          {
            "uid": 85,
            "address": "75 Tăng Bạt Hổ, phường 11, Bình Thạnh, Hồ Chí Minh, Vietnam",
            "latitude": 10.8106070721442,
            "longitude": 106.692920923233,
            "address_type": "home"
          }
        ]
      }

      - Status 422 in case invalid type
        {
          "success": false,
          "errors": "Invalid type"
        }
    EOS
  end

  def self.save_current_location_desc
    <<-EOS
    PUT 'http://gpdq.co.uk/api/v1/patients/maps/save_current_location
      PARAMS {"lat" => 51.522074, "lng": -0.060478, auth_token: "gHtdHHx6gEfWL7c6ckc5Vg", "address" => "123 E1 London UK"}

      - Status 200: return successfully
      {"success": true}

    EOS
  end

  def self.out_covarage_area_desc
    <<-EOS
    PUT 'http://gpdq.co.uk/api/v1/patients/maps/out_covarage_area
      PARAMS {"name" => "John", "email": "example@yopmail.com", post_code: "EC2"}

      - Status 200: in case submit info successfully
      {
        "success": true,
        "message": "Thanks for your submission."
      }

      - Status 422: in case patient already submit this info
      {
        "success": false,
        "errors": "You has already submit this info!"
      }

    EOS
  end

end