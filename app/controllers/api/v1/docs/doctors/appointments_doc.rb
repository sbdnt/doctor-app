class Api::V1::Docs::Doctors::AppointmentsDoc <  ActionController::Base

  def_param_group :cancel_appointment do
    param :id, Integer, desc: "Appointment id", :required => true
  end
  def_param_group :delayed_appointment do
    param :id, Integer, desc: "Appointment id", :required => true
    param :delay_time, Integer, desc: "Delay time", :required => true
  end
  def_param_group :invoice do
    param "items[item_1][id]", Integer, desc: "Item's id"
    param "items[item_1][quantity]", Integer, desc: "Item's quantity"
  end

  def self.confirm_on_way
    <<-EOS
      PUT 'http://gpdq.co.uk/api/v1/doctors/appointments/:id/confirm_on_way
      PARAMS  {"auth_token": "jkDsPGkGMs7pBQoLcWLIrA", "id": 22}
      ===> There are 4 cases:

      - Status 200 in case appointment was confirm on way successfully:
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

      - Status 401 in case invalid doctor auth token:
      {
        "message": "Unauthorized"
      }

      - Status 403 in case appointment can't be confirm on way:
      {
        "success": false,
        "errors": "Only confirmed appointment can be confirmed on way! This appointment's status is pending.",
        "appointment": {
          "uid": 191,
          "patient_id": 62,
          "doctor_id": 55,
          "patient_full_name": "Hang Trinh EC1",
          "start_time": "August 19, at 07:13AM",
          "short_start_time": "07:13AM",
          "estimated_time": 6,
          "status": "pending",
          "lat": 51.521223,
          "lng": -0.0433301,
          "address": "22 Ernest St, London E1 4LS, UK",
          "patient_phone": '12345678',
          "start_in_second": 999,
          "transport": 'transit'
        }
      }

      - Status 422 in case appointment not found:
      {
        "success": false,
        "errors": "Appointment not found or does not belong to you!"
      }

    EOS
  end

  def self.return_appointment
    <<-EOS
      PUT 'http://gpdq.co.uk/api/v1/doctors/appointments/:id/return_appointment
      PARAMS  {"auth_token": "jkDsPGkGMs7pBQoLcWLIrA", "id": 22}
      ===> There are 4 cases:
      Note: Will return doctor current appointment ONLY when doctor has any appointemnt

      - Status 200 in case appointment was returned successfully:
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
          "status": "assigned",
          "lat": 51.521223,
          "lng": -0.0433301,
          "address": "22 Ernest St, London E1 4LS, UK",
          "patient_phone": '12345678',
          "start_in_second": 999,
          "transport": 'transit'
        }
      }

      - Status 401 in case invalid doctor auth token:
      {
        "message": "Unauthorized"
      }

      - Status 403 in case appointment can't be returned:
      {
        "success": false,
        "errors": "Only confirmed on way appointment can be returned! This appointment's status is pending.",
        "appointment": {
          "uid": 191,
          "patient_id": 62,
          "doctor_id": 55,
          "patient_full_name": "Hang Trinh EC1",
          "start_time": "August 19, at 07:13AM",
          "short_start_time": "07:13AM",
          "estimated_time": 6,
          "status": "pending",
          "lat": 51.521223,
          "lng": -0.0433301,
          "address": "22 Ernest St, London E1 4LS, UK",
          "patient_phone": '12345678',
          "start_in_second": 999,
          "transport": 'transit'
        }
      }

      - Status 422 in case appointment not found:
      {
        "success": false,
        "errors": "Appointment not found or does not belong to you!"
      }

    EOS
  end

  def self.delayed_appointment
    <<-EOS
      Author: Thai
      Updated_by: Tan
      PUT 'http://gpdq.co.uk/api/v1/doctors/appointments/:id/delayed_appointment
        PARAMS  {"auth_token": "jkDsPGkGMs7pBQoLcWLIrA", "id": 22, "delay_time": 5}
        ===> There are 5 cases:

        - Status 422 in case ApiParameterMissing:
        {
          "message": "Missing parameters",
          "errors": "delay_time can't be blank",
          "success": false
        }

        - Status 200 in case appointment was delayed successfully:
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

        - Status 401 in case invalid doctor auth token:
        {
          "errors": "Unauthorized"
        }

        - Status 403 in case appointment can't delayed:
        {
          "success": false,
          "errors": "Only confirmed on way appointment can be delayed! This appointment's status is pending.",
          "appointment": {
            "uid": 191,
            "patient_id": 62,
            "doctor_id": 55,
            "patient_full_name": "Hang Trinh EC1",
            "start_time": "August 19, at 07:13AM",
            "short_start_time": "07:13AM",
            "estimated_time": 6,
            "status": "pending",
            "lat": 51.521223,
            "lng": -0.0433301,
            "address": "22 Ernest St, London E1 4LS, UK",
            "patient_phone": '12345678',
            "start_in_second": 999,
            "transport": 'transit'
          }
        }

        - Status 422 in case appointment not found:
        {
          "success": false,
          "errors": "Appointment not found or does not belong to you!"
        }

    EOS
  end

  def self.mark_appointment_started
    <<-EOS
      PUT 'http://gpdq.co.uk/api/v1/doctors/appointments/:id/mark_appointment_started
      PARAMS  {"auth_token": "jkDsPGkGMs7pBQoLcWLIrA", "id": 22}
      ===> There are 4 cases:

      - Status 200 in case appointment was mark as started successfully:
      {
        "success": true
      }

      - Status 401 in case invalid doctor auth token:
      {
        "errors": "Unauthorized"
      }

      - Status 403 in case appointment can't mark as started:
      {
        "success": false,
        "errors": "Only confirmed on way appointment can be marked started! This appointment's status is pending."
      }

      - Status 422 in case appointment not found:
      {
        "success": false,
        "errors": "Appointment not found or does not belong to you!"
      }

    EOS
  end

  def self.get_patient_phone
    <<-EOS
      PUT 'http://gpdq.co.uk/api/v1/doctors/appointments/:id/get_patient_phone
      PARAMS  {"auth_token": "jkDsPGkGMs7pBQoLcWLIrA", "id": 22}
      ===> There are 3 cases:

      - Status 200 in case get patient's phone successfully:
      {
        "success": true,
        "patient_phone": "John Smith"
        "patient_phone": "09090909"
      }

      - Status 401 in case invalid doctor auth token:
      {
        "message": "Unauthorized"
      }

      - Status 422 in case appointment not found:
      {
        "success": false,
        "errors": "Appointment not found or does not belong to you!"
      }

    EOS
  end

  def self.show
    <<-EOS
      Author: Thanh
      GET http://gpdq.co.uk/api/v1/doctors/appointments/:id
      PARAMS  {"auth_token": "jkDsPGkGMs7pBQoLcWLIrA", "id": "22"}
      ===> There are 2 cases:

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
          "status": "confirmed",
          "lat": 51.521223,
          "lng": -0.0433301,
          "address": "22 Ernest St, London E1 4LS, UK",
          "patient_phone": '12345678',
          "start_in_second": 999,
          "transport": 'transit'
        }
      }
      (Status can have one of these values: pending, assigned, confirmed, on_way, on_process, complete.)

      - Fail - Status 422:
      {
        "success": false,
        "errors": "This appointment does not exists."
      }
    EOS
  end

  def self.counted_by_months
    <<-EOS
    Author: Thanh
    GET http://gpdq.co.uk/api/v1/doctors/appointments/counted_by_months
    PARAMS  { "auth_token": "jkDsPGkGMs7pBQoLcWLIrA" }
    ===> There are 1 case:

    - Success - Status 200: 
    {
      "appointments_count": [
        {
          "month": "JULY",
          "count": 35
        },
        {
          "month": "AUGUST",
          "count": 49
        }
      ]
    }
    EOS
  end

  def self.counted_in_month
    <<-EOS
    Author: Thanh
    GET http://gpdq.co.uk/api/v1/doctors/appointments/counted_in_month
    PARAMS  { "auth_token": "jkDsPGkGMs7pBQoLcWLIrA", "month_name": "October" }
    Month names: "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
    (month name can be uppercase or lowercase)
    ===> There are 1 case:

    - Success - Status 200: 
    {
      "appointments": [
        {
          "uid": 191,
          "patient_name": "Hang Trinh EC1",
          "created_at": "08/19/2015 - 08:13AM",
          "address": "22 Ernest St, London E1 4LS, UK",
          "status": "cancelled",
          "total_invoice": 0
        },
        {
          "uid": 190,
          "patient_name": "Hang Trinh EC1",
          "created_at": "08/18/2015 - 10:58AM",
          "address": "466 Lê Quang Định, phường 11, Hồ Chí Minh, Vietnam",
          "status": "returned",
          "total_invoice": 0
        },
        {
          "uid": 189,
          "patient_name": "Hang Trinh EC1",
          "created_at": "08/18/2015 - 10:56AM",
          "address": "466 Lê Quang Định, phường 11, Hồ Chí Minh, Vietnam",
          "status": "completed",
          "total_invoice": 30.0
        }
      ]
    }
    EOS
  end

  def self.upcoming 
    <<-EOS
    Author: Thanh
    GET http://gpdq.co.uk/api/v1/doctors/appointments/upcoming
    PARAMS  { "auth_token": "jkDsPGkGMs7pBQoLcWLIrA" }
    ===> There are 1 case:
    {
      "appointments": [
        {
          "uid": 188,
          "patient_name": "Hang Trinh EC1",
          "created_at": "08/17/2015 - 04:50AM",
          "address": "466 Lê Quang Định, phường 11, Hồ Chí Minh, Vietnam"
        },
        {
          "uid": 189,
          "patient_name": "Hang Trinh EC1",
          "created_at": "08/18/2015 - 10:56AM",
          "address": "466 Lê Quang Định, phường 11, Hồ Chí Minh, Vietnam"
        }
      ]
    }
    EOS
  end

  def self.create_invoice
    <<-EOS
      POST 'http://gpdq.co.uk/api/v1/doctors/appointments/:id/create_invoice
      PARAMS  {"auth_token"=>"LSXxrIP4KPOWpZv1O7012A", "items"=>[{"id"=>"4", "quantity"=>"1", "price"=>"10.5"}, {"id"=>"5", "quantity"=>"8"}], "id"=>"76"}
      ===> There are 4 cases:

      - Status 200 in case doctor created an invoice successfully:
      {
        "success": true,
        "invoice": {
          "uid": 40,
          "appointment_id": 76,
          "total_extra": "2,490.00",
          "total_prices": "5,767.00"
        }
      }

      - Status 401 in case invalid doctor auth token:
      {
        "message": "Unauthorized"
      }

      - Status 403 in case appointment is not valid to create invoice:
      { "success": false, 
        "errors": "You can't create invoice for this appointment!"
      }

      - Status 422 in case appointment not found:
      {
        "success": false,
        "errors": "Appointment not found or does not belong to you!"
      }
      - Other APIs related:
        - Get charges list: http://gpdq.co.uk/apidoc/doctors/charges/charges.html

    EOS
  end

  def self.current
    <<-EOS
    Author: Thanh
    GET http://gpdq.co.uk/api/v1/doctors/appointments/current
    PARAMS  { "auth_token": "jkDsPGkGMs7pBQoLcWLIrA" }
    ===> There are 2 cases:

    - Appointment - Status 200: 
    {
      "appointment": {
        "uid": 191,
        "patient_id": 62,
        "doctor_id": 55,
        "patient_full_name": "Hang Trinh EC1",
        "start_time": "August 19, at 07:13AM",
        "short_start_time": "07:13AM",
        "estimated_time": 6,
        "status": "assigned", (Status can have one of these values: pending, assigned, confirmed, on_way, on_process, complete.)
        "lat": 51.521223,
        "lng": -0.0433301,
        "address": "22 Ernest St, London E1 4LS, UK",
        "patient_phone": '12345678',
        "start_in_second": 999,
        "transport": 'transit'
      }
    }

    - No appointment - Status 200:
    {}

    ---- NOTES ----
    - create appointment => pending
    - assigned doctor => assigned
    - doctor chọn on my way => on way
    - doctor chọn delay 5 mins => on way nhưng start_at sẽ được update lại và cộng thêm 5p
    - doctor chọn return => pending hoặc assigned nếu assign được cho doctor khác
    - doctor chọn appointment started => on process
    - doctor chọn end appointment => completed
    ---- END NOTES ----

    EOS
  end

  def self.next_appointments
    <<-EOS
    Author: Tan
    GET http://gpdq.co.uk/api/v1/doctors/appointments/next_appointments
      PARAMS  { "auth_token": "jkDsPGkGMs7pBQoLcWLIrA" }
      ===> There are 3 cases:

      - Failed (in case unauthorized) - Status 401:
      {
        "message": "Unauthorized"
      }

      - Succees (in case get next appointments successfully) - Status 200
      {
        "success": true,
        "next_appointments": 
        [{:uid=>493,
          :patient_id=>247,
          :doctor_id=>111,
          :patient_full_name=>"tuan",
          :start_time=>"September 21, at 07:23AM",
          :short_start_time=>"07:23AM",
          :estimated_time=>9,
          :status=>"assigned",
          :lat=>51.51065826,
          :lng=>-0.05510531,
          :address=>"6 Sage St, Luân Đôn, Vương Quốc Anh"},
         {:uid=>495,
          :patient_id=>249,
          :doctor_id=>111,
          :patient_full_name=>"tan@yopmail.com",
          :start_time=>"September 21, at 07:57AM",
          :short_start_time=>"07:57AM",
          :estimated_time=>28,
          :status=>"complete",
          :lat=>51.5185345,
          :lng=>-0.0726849,
          :address=>"31 Fashion Street, London, United Kingdom"}]
      }

      - Failed (in case no next appointments found) - Status 400:
      {
        "success": false,
        "errors": "You don't have next appointments"
      }

    EOS
  end

  def self.confirm_appointment
    <<-EOS
      Author: Tan
      PUT 'http://gpdq.co.uk/api/v1/doctors/appointments/:id/confirm_appointment
      PARAMS  {"auth_token": "jkDsPGkGMs7pBQoLcWLIrA", "id": 22}
      ===> There are 4 cases:

      - Status 200 in case appointment was confirmed successfully:
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
          "status": "confirmed",
          "lat": 51.521223,
          "lng": -0.0433301,
          "address": "22 Ernest St, London E1 4LS, UK",
          "patient_phone": '12345678',
          "start_in_second": 999,
          "transport": 'transit'
        }
      }

      - Status 401 in case invalid doctor auth token:
      {
        "message": "Unauthorized"
      }

      - Status 403 in case appointment can't be confirmed:
      {
        "success": false,
        "errors": "Only assigned appointment can be confirmed! This appointment's status is pending.",
        "appointment": {
          "uid": 191,
          "patient_id": 62,
          "doctor_id": 55,
          "patient_full_name": "Hang Trinh EC1",
          "start_time": "August 19, at 07:13AM",
          "short_start_time": "07:13AM",
          "estimated_time": 6,
          "status": "confirmed",
          "lat": 51.521223,
          "lng": -0.0433301,
          "address": "22 Ernest St, London E1 4LS, UK",
          "patient_phone": '12345678',
          "start_in_second": 999,
          "transport": 'transit'
        }
      }

      - Status 422 in case appointment not found:
      {
        "success": false,
        "errors": "Appointment not found or does not belong to you!"
      }

    EOS
  end
end