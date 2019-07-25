class Api::V1::Doctors::DoctorsController < Api::V1::Doctors::BaseController

  api :GET, '/doctors/doctors/get_infos', "Get current doctor's information"
  param_group :base_group, Api::V1::Docs::Doctors::SessionsDoc
  example Api::V1::Docs::Doctors::DoctorsDoc.get_infos_desc
  def get_infos
    host = request.protocol + request.host_with_port
    render json: current_doctor
  end

  api :PUT, '/doctors/doctors/select_transportation_method', "Doctor select transportation method"
  param_group :base_group, Api::V1::Docs::Doctors::SessionsDoc
  param :transportation, String, desc: "Values include: driving, walking, transit", required: true
  example Api::V1::Docs::Doctors::DoctorsDoc.select_transportation_method_desc
  def select_transportation_method
    transport = params[:transportation] == "transit" ? "driving" : params[:transportation]
    is_transit = params[:transportation] == "transit" ? true : false
    appointment = Appointment.where(doctor_id: current_doctor.id).active.order('assigned_time_at asc').first
    appointment.update_attributes(transport: params[:transportation]) if appointment.present?
    success = current_doctor.update_attributes(transportation: transport, is_transit: is_transit)

    if appointment.present?
      render json: {success: success, appointment: appointment.reload.detail_as_json}
    else
      render json: {success: success}
    end
  end

  api :PUT, '/doctors/doctors/update_location', "Update doctor latitude and longitude"
  param_group :base_group, Api::V1::Docs::Doctors::SessionsDoc
  param :lat, Float, "Doctor's latitude (Decimal precision 12, scale 8)", required: true
  param :lng, Float, "Doctor's longitude (Decimal precision 12, scale 8)", required: true
  param :address, String, "Doctor's address", required: true
  example Api::V1::Docs::Doctors::DoctorsDoc.update_location
  def update_location
    if params[:address].present?
      update_address = params[:address]
    else
      update_address = Geocoder.address([params[:lat], params[:lng]])
      sleep 0.1
    end

    update_address ||= current_doctor.address
    if current_doctor.update_attributes(address: update_address, latitude: params[:lat], longitude: params[:lng])
      render json: { doctor: current_doctor }, status: 200
    else
      render json: { errors: current_doctor.errors.full_messages.first }, status: 422
    end
  end

  api! "Find doctors around"
  param_group :base_group, Api::V1::Docs::Doctors::SessionsDoc
  param :range, Integer, "Distance around. Default is 5 miles"
  example Api::V1::Docs::Doctors::DoctorsDoc.find_doctors_around
  def find_doctors_around
    if current_doctor.latitude && current_doctor.longitude
      doctors = current_doctor.find_doctors_around(range: params[:range])
    else
      doctors = []
    end
    render json: { doctors: doctors }, status: 200
  end

  api :PUT, '/doctors/doctors/update_working_status', 'Doctor registers working status (ON/OFF)'
  param_group :base_group, Api::V1::Docs::Doctors::SessionsDoc
  param :working_status, String, desc: "Doctor's on duty", :required => true
  example Api::V1::Docs::Doctors::DoctorsDoc.update_working_status
  def update_working_status
    case params[:working_status]
    when 'on'
      current_doctor.update_columns(available: true) if !current_doctor.available?

    when 'off'
      on_way_appointments = current_doctor.appointments.where(status: Appointment.statuses[:on_way], is_canceled: Appointment.is_canceleds[:normal])
      if on_way_appointments.any?
        render json: { success: false, errors: "This appointment is confirmed as 'on way', you need to return it before you stop working!", is_working: current_doctor.available }, status: 422 and return
      end

      on_process_appointments = current_doctor.appointments.where(status: Appointment.statuses[:on_process], is_canceled: Appointment.is_canceleds[:normal])
      if on_process_appointments.any?
        render json: { success: false, errors: "This appointment is confirmed as 'on process', you need to finish it before you stop working!", is_working: current_doctor.available }, status: 422 and return
      end

      current_doctor.update_columns(available: false) if current_doctor.available?

    else
      render json: { success: false, errors: 'Unavailable status', is_working: current_doctor.available }, status: 422 and return
    end

    error_message = current_doctor.errors.full_messages.first
    if error_message.nil?              
      render json: { success: true, is_working: current_doctor.available }, status: 200
    else
      render json: { success: false, errors: error_message, is_working: current_doctor.available }, status: 422
    end
  end

  api! "Update doctor's device token"
  param_group :base_group, Api::V1::Docs::Doctors::SessionsDoc
  param :device_token, String, desc: "Doctor's device_token", required: true
  param :platform, String, desc: "Device platform, value = ios/android", required: true
  example Api::V1::Docs::Doctors::DoctorsDoc.update_device_token
  def update_device_token
    required :device_token
    required :platform
    if current_doctor.update(device_token: params[:device_token], platform: params[:platform])
      short_data_updated = { 
        uid: current_doctor.id,
        device_token: current_doctor.device_token,
        platform: current_doctor.platform
      }
      render json: { doctor: short_data_updated }, status: 200
    else
      render json: { errors: current_doctor.errors.full_messages.first }, status: 422
    end
  end
end
