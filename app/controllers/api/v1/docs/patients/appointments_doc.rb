class Api::V1::Docs::Patients::AppointmentsDoc <  ActionController::Base

  def_param_group :cancel_appointment do
    param :id, Integer, desc: "Appointment id", :required => true
  end

  def_param_group :patient_invoice do
    param :appointment_id, Integer, desc: "Appointment id", :required => true
  end
  def_param_group :rating_params do
    param :id, Integer, desc: "Appointment id", required: true
    param :rating_of_quality, Integer, desc: "Rating of quality, value: 1..5", required: true
    param :rating_of_manner, Integer, desc: "Rating of manner, value: 1..5", required: true
    param :comment, String, desc: "Text: User can comment here."
  end

  def_param_group :get_apt do
    param :scope, String, desc: "Scope to find appointments", :required => true
  end

  def_param_group :appointment do
    param :appointment, Hash, required: true, desc: "Appointment info" do
      param :paymentable_id, Integer, desc: "Id of PatientCreditPayment/PatientPaypalPayment", required: true
      param :paymentable_type, String, desc: "Paymentable Type: PatientCreditPayment/PatientPaypalPayment", required: true
      param :lat, Float, "Appointment's latitude (Decimal precision 12, scale 8)", required: true
      param :lng, Float, "Appointment's longitude (Decimal precision 12, scale 8)", required: true
      param :address, String, "Appointment address", required: true
      param :lat_bill_address, Float, "Billing address's latitude (Decimal precision 12, scale 8)", required: true
      param :lng_bill_address, Float, "Billing address's longitude (Decimal precision 12, scale 8)", required: true
      param :bill_address, String, "Billing address", required: true
    end
    param :voucher_code, String, desc: "Voucher code"
  end

  def self.index
    <<-EOS
      Updated: Thanh
      GET http://gpdq.co.uk/api/v1/patients/appointments
      PARAMS  {"auth_token": "jkDsPGkGMs7pBQoLcWLIrA", "scope": "live"}
      "scope" in ["live", "past"]
      ===> There are 4 cases:

      - Live appointments (on way, on process and assigned appointments) - Status 200:
      {
        appointments: [
          {
            "uid": 129,
            "doctor_id": 57,
            "doctor_name": "hang. trinh EC1",
            "start_at": "08/17/2015 - 03:32AM",
            "short_start_time": "03:32AM",
            "is_canceled": false,
            "lat": 51.521223,
            "lng": -0.0433301,
            "address": "466 Lê Quang Định, phường 11, Hồ Chí Minh, Vietnam",
            "voucher_code": "GD66-WFQQ-WQDD",
            "total_credits": 0,
            "payment_method": {
              "cc_num": "",
              "cc_type": "",
              "paypal_email": "test@paypal.com"
            },
            "appointment_fee": 120.0
          },
          {
            "uid": 130,
            "doctor_id": 57,
            "doctor_name": "hang. trinh EC1",
            "start_at": "08/17/2015 - 03:32AM",
            "short_start_time": "03:32AM",
            "is_canceled": false,
            "lat": 51.521223,
            "lng": -0.0433301,
            "address": "466 Lê Quang Định, phường 11, Hồ Chí Minh, Vietnam",
            "voucher_code": "",
            "total_credits": 123.45,
            "payment_method": {
              "cc_num": "5168xxxxxxxx6077",
              "cc_type": "mastercard",
              "paypal_email": ""
            },
            "appointment_fee": 120.0
          }
        ]
      }

      - Past appointments - Status 200:
      {
        appointments: [
          {
            "uid": 129,
            "doctor_id": 57,
            "doctor_name": "hang. trinh EC1",
            "start_at": "08/17/2015 - 03:32AM",
            "is_canceled": false,
            "lat": 51.521223,
            "lng": -0.0433301,
            "address": "466 Lê Quang Định, phường 11, Hồ Chí Minh, Vietnam",
            "is_rated": false,
            "total_invoice": "100,000.46",
            "voucher_code": "GD66-WFQQ-WQDD",
            "total_credits": 0,
            "payment_method": {
              "cc_num": "",
              "cc_type": "",
              "paypal_email": "test@paypal.com"
            },
            "appointment_fee": 120.0
          }
        ]
      }

      - Missing parameters - Status 422:
      {
        "message": "Missing parameters",
        "errors": "scope can't be blank"
      }

      - Unauthorized - Status 401:
      {
        "message": "Unauthorized"
      }
    EOS
  end

  def self.cancel_appointment
    <<-EOS
      PUT 'http://gpdq.co.uk/api/v1/patients/appointments/:id/cancel_appointment
      PARAMS  {"auth_token": "jkDsPGkGMs7pBQoLcWLIrA", "id": "22"}
      ===> There are 4 cases:

      - Status 200 in case appointment was canceled successfully:
      {
        "success": true
      }

      - Status 401 incase invalid patient auth token:
      {
        "message": "Unauthorized"
      }

      - Status 403 incase invalid appointment can't be canceled:
      {
        "success": false,
        "errors": "Appointment can't be canceled! Your appointment has already canceled."
      }

      - Status 422 incase appointment not found:
      {
        "success": false,
        "errors": "Appointment not found or it does not belong to you!"
      }

    EOS
  end

  def self.summary_desc
    <<-EOS
      Updated: Thanh - Reload patient before get min eta
      Last Updated: Tan - add address
      GET http://gpdq.co.uk/api/v1/patients/appointments/summary
      PARAMS  {"auth_token": "jkDsPGkGMs7pBQoLcWLIrA", "lat" => "51.520445", "lng" => "-0.066551", "address" => "123 E1 London UK"}
      - For case: logged user
        {"arrival_time" => "11:30AM", "appointment_fee" => 246.0}
      - For case: unlogged user
        {"arrival_time" => "", "appointment_fee" => 246.0}

    EOS
  end

  def self.booking_confirmed_desc
    <<-EOS
      GET 'http://gpdq.co.uk/api/v1/patients/appointments/booking_confirmed
      PARAMS  {"auth_token": "jkDsPGkGMs7pBQoLcWLIrA"}
        - For empty result
        {
          "arrival_time": null,
          "doctor_profile": {}
        }

        - for full result:
        {
          "arrival_time": null,
          "doctor_profile": {
            "id": 2,
            "avatar": "http://localhost:3000/uploads/doctor/avatar/2/bong_bay.jpg",
            "fullname": "Jonh smith"
          }
        }

    EOS
  end

  def self.rating_desc
    <<-EOS
      PUT 'http://gpdq.co.uk/api/v1/patients/appointments/:id/rating
      PARAMS  {"auth_token": "jkDsPGkGMs7pBQoLcWLIrA"}
        - Return status 400 with errors:
        {
          "success": false,
          "errors": "Rating  must less than or equal 5."
        }

        - Return status 200 in case succecssfully:
        {
          success: true
        }

        - Return error if appointment's is does not exist:

        {
          "success": false,
          "errors": "Appointment's id does not exist."
        }


    EOS
  end

  def self.rating_detail
    <<-EOS
      GET 'http://gpdq.co.uk/api/v1/patients/appointments/:id/rating_detail
      PARAMS  {"auth_token": "jkDsPGkGMs7pBQoLcWLIrA"}

      ===> There are 3 cases:
        - Status 200 in case get rating detail succecssfully:
        {
          "doctor": {
            "fullname": "doctor 7",
            "avatar_url": "/uploads/doctor/avatar/7/thumb_IMG_2023_copy.JPG"
          },
          "quality": 3,
          "manner": 2,
          "comment": ""
        }

        - Status 401 incase invalid patient auth token:
        {
          "message": "Unauthorized"
        }

        - Status 422 in case appointment not found:
        {
          "success": false,
          "errors": "Appointment not found or it does not belong to you!"
        }
    EOS
  end

  def self.create
    <<-EOS
      Updated: Tan - check for booking time
      POST 'http://gpdq.co.uk/api/v1/patients/appointments
      PARAMS  {"auth_token": "jkDsPGkGMs7pBQoLcWLIrA",
               "appointment" => {
                  "paymentable_id" => "1",
                  "paymentable_type" => "PatientCreditPayment",
                  "lat"=>"10.8156995", 
                  "lng"=>"106.688687", 
                  "address"=>"466 Lê Quang Định, phường 11, Hồ Chí Minh, Vietnam", 
                  "lat_bill_address"=>"10.8156995", 
                  "lng_bill_address"=>"106.688687", 
                  "bill_address"=>"466 Lê Quang Định, phường 11, Hồ Chí Minh, Vietnam"
               },
               "voucher_code" => "GPDQ2015"
      }
      ===> There are 7 cases:
        - Success:
          {
            "success": true
          }
          Status 201 Created

        # not run this now, will turn on if get change
        # - Fail:
        #   {
        #     "success": false
        #     "error": "Sorry, there are no available doctors to create this appointment. Our doctors' working time is from 8:00 AM to 11:00 PM"
        #   }
        #   Status 422 Unprocessable Entity

        - Fail:
          {
            "success": false
            "error": "Your current appointment is not complete!"
          }
          Status 422 Unprocessable Entity

        - Fail:
          {
            "success": false
            "error": "Paymentable type can't be blank"
          }
          Status 422 Unprocessable Entity

        - Fail:
          {
            "success": false
            "error": "This voucher code already used!"
          }
          Status 422 Unprocessable Entity

        - Fail:
          {
            "success": false
            "error": "This voucher code not found!"
          }
          Status 422 Unprocessable Entity

        - Fail:
          {
            "success": false
            "error": "Credit card is invalid!"
          }
          Status 422 Unprocessable Entity

      - Other APIs related:
        - Get Id and Paymentable type: http://gpdq.co.uk/api/v1/patients/patients
        - Check validate voucher code: http://gpdq.co.uk/api/v1/vouchers/:voucher_code/validate
    EOS
  end

  def self.doctor_info
    <<-EOS
      Author: Thanh
      Updated: Tan - change available to is_working
      Updated: Thanh - Add start_in_second key for appointment
      GET http://gpdq.co.uk/api/v1/patients/appointments/doctor_info
      PARAMS  {"auth_token": "jkDsPGkGMs7pBQoLcWLIrA"}
      ===> There are 2 cases:

      - Doctor assigned to appointment - Status 200:
      {
        "doctor": {
          "uid": 55,
          "email": "hang.trinh@yopmail.com",
          "avatar_url": null,
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
          "transportation": "driving" (Transportation has one of these values: driving, transit, walking. Default is driving.)
        },
        "appointment": {
          "uid": 191,
          "patient_id": 62,
          "doctor_id": 55,
          "patient_full_name": "Hang Trinh EC1",
          "start_time": "August 19, at 07:13AM",
          "short_start_time": "07:13AM",
          "estimated_time": 8,
          "status": "assigned", (Status can have one of these values: pending, assigned, confirmed, on_way, on_process, complete.)
          "lat": 51.521223,
          "lng": -0.0433301,
          "address": "22 Ernest St, London E1 4LS, UK",
          "patient_phone": "123456",
          "start_in_second": 1989,
          "transport": 'transit'
        }
      }

      - Doctor is not assigned to appointment - Status 200:
      {
        "appointment": {
          "uid": 134,
          "patient_id": 62,
          "doctor_id": null,
          "patient_full_name": "Hang Trinh EC1",
          "start_time": "August 19, at 07:13AM",
          "short_start_time": "07:13AM",
          "estimated_time": -1,
          "status": "assigned",
          "lat": 51.521223,
          "lng": -0.0433301,
          "address": "22 Ernest St, London E1 4LS, UK",
          "patient_phone": "123456",
          "start_in_second": 1989,
          "transport": 'transit'
        }
      }

      - No appointment - Status 200:
      {}
    EOS
  end

  def self.final_invoice
    <<-EOS
      GET 'http://gpdq.co.uk/api/v1/patients/appointments/:id/final_invoice
      PARAMS  {"auth_token": "jkDsPGkGMs7pBQoLcWLIrA"}
      ===> There are 4 cases:

      - Status 200 in case get final invoice of appointment successfully:
      {
        "invoice": {
          "uid": 43,
          "appointment_id": 12,
          "total_extra": "0.00",
          "total_prices": "3,934.40",
          "created_at": "OCTOBER 12, 2015 AT 09:20AM"
        },
        "categories": [
          {
            "uid": 1,
            "name": "Drug",
            "items": [
              {
                "uid": 8,
                "name": "Default 1",
                "price_per_unit": 120,
                "quantity": 1,
                "category_id": 1,
                "is_default": true,
                "desc": ""
              },
              {
                "uid": 9,
                "name": "Default 2",
                "price_per_unit": 220,
                "quantity": 1,
                "category_id": 1,
                "is_default": true,
                "desc": ""
              }
            ],
            "allow_expand": true,
            "allow_patient_expand" :true
          },
          {
            "uid": 3,
            "name": "Appointment",
            "items": [
              {
                "uid": 12,
                "name": "price for appointment",
                "price_per_unit": 100,
                "quantity": 1,
                "category_id": 3,
                "is_default": true,
                "desc": ""
              },
              {
                "uid": 15,
                "name": "New default",
                "price_per_unit": 10,
                "quantity": 1,
                "category_id": 3,
                "is_default": true,
                "desc": "new"
              }
            ],
            "allow_expand": true,
            "allow_patient_expand" :false
          },
          {
            "uid": 4,
            "name": "Extra Appt Extension",
            "items": [
              {
                "uid": 13,
                "name": "price for appt extension",
                "price_per_unit": 50,
                "quantity": 1,
                "category_id": 4,
                "is_default": true,
                "desc": ""
              }
            ],
            "allow_expand": true,
            "allow_patient_expand" :true
          },
          {
            "uid": 5,
            "name": "Extra drug delivery",
            "items": [
              {
                "uid": 14,
                "name": "price for drug",
                "price_per_unit": 70,
                "quantity": 1,
                "category_id": 5,
                "is_default": true,
                "desc": ""
              }
            ],
            "allow_expand": true,
            "allow_patient_expand" :true
          },
          {
            "name": "Appointment Fee",
            "allow_expand": false,
            "items": [
              {
                "name": "Appointment Fee",
                "price_per_unit": 119,
                "quantity": 1
              }
            ]
          },
          {
            "name": "Extras",
            "allow_expand": true,
            "allow_patient_expand" :false
            "items": [
              {
                "name": "Extras",
                "price_per_unit": 119,
                "quantity": 1,
                "extend_time": "10 mins"
              }
            ]
          }
        ],
        "appointment_rated": true,
        "doctor_name": "Doctor"
      }

      - Status 200 in case appointment not has final invoice yet:
      {}

      - Status 401 incase invalid patient auth token:
      {
        "message": "Unauthorized"
      }

      - Status 422 incase appointment not found:
      {
        "success": false,
        "errors": "Appointment not found or does not belong to you!"
      }
    EOS
  end

  def self.price_list
    <<-EOS
      GET 'http://gpdq.co.uk/api/v1/patients/appointments/price_list

      ===> There are 2 cases:
        - Status 200 in case get price list with description succecssfully:
        {
          "price_list": [
            {
              "uid": 1,
              "name": "Monday - Friday",
              "price": "£119.00"
            },
            {
              "uid": 2,
              "name": "Saturday - Sunday",
              "price": "£149.00"
            },
            {
              "uid": 3,
              "name": "Bank holidays",
              "price": "£200.00"
            },
            {
              "uid": 4,
              "name": "Extras",
              "price": "£5.00 per min"
            },
            {
              "uid": 5,
              "name": "Drug delivery",
              "price": "Price dependent on prescription"
            }
          ],
          "desc": "Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in the place"
        }

        - Status 200 in case get price list without description succecssfully:
        {
          "price_list": [
            {
              "uid": 1,
              "name": "Monday - Friday",
              "price": "£119.00"
            },
            {
              "uid": 2,
              "name": "Saturday - Sunday",
              "price": "£149.00"
            },
            {
              "uid": 3,
              "name": "Bank holidays",
              "price": "£200.00"
            },
            {
              "uid": 4,
              "name": "Extras",
              "price": "£5.00 per min"
            },
            {
              "uid": 5,
              "name": "Drug delivery",
              "price": "Price dependent on prescription"
            }
          ]
        }

    EOS
  end

  def self.pending_invoice
    <<-EOS
      GET 'http://gpdq.co.uk/api/v1/patients/appointments/pending_invoice
      PARAMS  {"auth_token": "jkDsPGkGMs7pBQoLcWLIrA"}

        - Return status 200 in case patient doesn't have any pending invoice:
        {}

        - Return status 200 in case patient has pending invoice:
        {
          "invoices": [
            {
              "uid": 43,
              "appointment_id": 12,
              "total_extra": "0.00",
              "total_prices": "3,934.40",
              "appointment_fee": "100.0",
              "vat": "20%",
              "created_at": "09/07/2015 05:27:03AM"
            }
          ]
        }

        - Return status 401 in case unauthorize:
        {
          "message": "Unauthorized"
        }
    EOS
  end
end