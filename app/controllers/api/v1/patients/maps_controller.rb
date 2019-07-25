class Api::V1::Patients::MapsController < Api::V1::BaseApiController
  skip_before_filter :api_authenticate_patient!, only: [:save_address, :save_billing_address, :find_doctor_around, :out_covarage_area]

  api :PUT, '/patients/maps/save_address', 'Save/Update address for patient'
  param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  param_group :address_param, Api::V1::Docs::Patients::MapsDoc
  example Api::V1::Docs::Patients::MapsDoc.save_address_desc
  def save_address
    # required :address
    required :auth_token
    required :address
    required :latitude
    required :longitude
    # required :address_type
    required :is_bill_address

    is_bill_address = params[:is_bill_address].is_a?(String) ? StringUtility.to_boolean(params[:is_bill_address]) : params[:is_bill_address]
    if params[:location_id].present?
      location = current_patient.locations.where(id: params[:location_id]).first
      location_existed = current_patient.locations.where(is_bill_address: is_bill_address, address: params[:address], latitude: params[:latitude], longitude: params[:longitude], address_type: Location.address_types[params[:address_type]]).first
      if location && location_existed.blank?
        location.update_attributes({address: params[:address], latitude: params[:latitude], 
                                    longitude: params[:longitude], address_type: params[:address_type],
                                    is_bill_address: is_bill_address
                                  })
        render json: {success: true, location: location.as_json}
      elsif location_existed.present?
        render json: {success: false, errors: "Location has been already taken!"}
      else
        render json: {success: false, errors: "Location not found!"}
      end
    else
      success = current_patient.save_address(is_bill_address, params[:address], params[:latitude].to_f, 
                                              params[:longitude].to_f, params[:address_type]
                                            )
      if success[:success]
        render json: {success: true, location: success[:location]}
      else
        render json: {success: false, errors: "Location can't be saved!"}
      end
    end
  end

  api :GET, '/patients/maps/find_doctor_around', 'Get availables doctors for patient'
  param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  param_group :doctor_around_param, Api::V1::Docs::Patients::MapsDoc
  example Api::V1::Docs::Patients::MapsDoc.find_doctor_around_old_desc
  def find_doctor_around
    address = URI.unescape(params[:address]) if params[:address]
    min_eta = 0
    has_no_doctor = true
    if current_patient
      doctors = current_patient.find_doctor_around(params[:lat].to_f, params[:lng].to_f, address, params[:range])
      # puts "---API doctors = #{doctors.inspect}"

      # Find patient to get new data
      current_patient.reload
      # puts "---API doctors = #{doctors.inspect}"

      # Update lat, lng to detect patient's selected zone
      # patient.save_current_location(params[:lat].to_f, params[:lng].to_f, address)
      if current_patient.zone_id.nil?
        render status: 422, json: {success: false, errors: "You've requested an appointment in an area not yet covered by GPDQ, however we are continually expanding and hope to cover your area soon. Please click here to register."}
        return
      end

      current_min_eta = current_patient.get_min_eta
      if current_min_eta.present? && current_min_eta.second.present?
        min_eta = current_min_eta.second
        min_eta = 10 if min_eta < 10
        has_no_doctor = false
      end
    else
      # temp_patient = TempPatient.where(latitude: params[:lat].to_f, longitude: params[:lng].to_f).first
      # temp_patient = TempPatient.new if temp_patient.nil?
      if address.present?
        temp_patient = TempPatient.find_or_create_by(address: address)
      else
        temp_patient = TempPatient.new
      end
      temp_patient.save_location(params[:lat].to_f, params[:lng].to_f, address)

      if temp_patient.zone_id.nil?
        render status: 422, json: {success: false, errors: "You've requested an appointment in an area not yet covered by GPDQ, however we are continually expanding and hope to cover your area soon. Please click here to register."}
        return
      end

      available_doctors = temp_patient.available_etas
      has_no_doctor = false if available_doctors.any?
      doctors = temp_patient.find_doctor_around(params[:lat].to_f, params[:lng].to_f, address, params[:range])
      min_eta = temp_patient.get_min_eta
      min_eta = 10 if min_eta.present? && min_eta < 10
    end

    if has_no_doctor
      render status: 424, json: {success: false, errors: "We are currently experiencing high demand. Please contact GPDQ to book your appointment for a later time"}
      return
    else
      render json: {doctor_infos: doctors, min_eta: min_eta}
    end
  end

  api :PUT, '/patients/maps/find_doctor_around', 'Get availables doctors for patient'
  param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  param_group :doctor_around_param, Api::V1::Docs::Patients::MapsDoc
  example Api::V1::Docs::Patients::MapsDoc.find_doctor_around_desc
  def find_doctor_around
    address = URI.unescape(params[:address]) if params[:address]
    min_eta = 0
    has_no_doctor = true
    if current_patient
      doctors = current_patient.find_doctor_around(params[:lat].to_f, params[:lng].to_f, address, params[:range])
      # puts "---API doctors = #{doctors.inspect}"

      # Find patient to get new data
      current_patient.reload
      # puts "---API doctors = #{doctors.inspect}"

      # Update lat, lng to detect patient's selected zone
      # patient.save_current_location(params[:lat].to_f, params[:lng].to_f, address)
      if current_patient.zone_id.nil?
        render status: 422, json: {success: false, errors: "You've requested an appointment in an area not yet covered by GPDQ, however we are continually expanding and hope to cover your area soon. Please click here to register."}
        return
      end

      current_min_eta = current_patient.get_min_eta
      if current_min_eta.present? && current_min_eta.second.present?
        min_eta = current_min_eta.second
        min_eta = 10 if min_eta < 10
        has_no_doctor = false
      end
    else
      # temp_patient = TempPatient.where(latitude: params[:lat].to_f, longitude: params[:lng].to_f).first
      # temp_patient = TempPatient.new if temp_patient.nil?
      if address.present?
        temp_patient = TempPatient.find_or_create_by(address: address)
      else
        temp_patient = TempPatient.new
      end
      temp_patient.save_location(params[:lat].to_f, params[:lng].to_f, address)

      if temp_patient.zone_id.nil?
        render status: 422, json: {success: false, errors: "You've requested an appointment in an area not yet covered by GPDQ, however we are continually expanding and hope to cover your area soon. Please click here to register."}
        return
      end

      available_doctors = temp_patient.available_etas
      has_no_doctor = false if available_doctors.any?
      doctors = temp_patient.find_doctor_around(params[:lat].to_f, params[:lng].to_f, address, params[:range])
      min_eta = temp_patient.get_min_eta
      min_eta = 10 if min_eta.present? && min_eta < 10
    end

    if has_no_doctor
      render status: 424, json: {success: false, errors: "We are currently experiencing high demand. Please contact GPDQ to book your appointment for a later time"}
      return
    else
      render json: {doctor_infos: doctors, min_eta: min_eta}
    end
  end

  api :PUT, '/patients/maps/save_billing_address', 'Save/Update billing address for patient'
  param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  param_group :address_param, Api::V1::Docs::Patients::MapsDoc
  example Api::V1::Docs::Patients::MapsDoc.save_billing_address
  def save_billing_address
    required :auth_token
    required :address
    required :latitude
    required :longitude
    if params[:address].blank?
      render json: {
            message: "Missing parameters", errors: "Address can't be blank" }
    else
      if current_patient.present?
        success = current_patient.save_billing_address(params[:address], params[:latitude], params[:longitude])
        if success[:success]
          render json: {success: true, location: success[:location]}
        else
          render json: {success: success, errors: patient.errors.full_messages[0]}
        end
      else
        render json: {success: true, location: success[:location]}
      end
    end
  end

  api :GET, '/patients/maps/get_last_addresses', 'Get last addresses(address/billing address) for patient'
  param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  param_group :get_billing, Api::V1::Docs::Patients::MapsDoc
  example Api::V1::Docs::Patients::MapsDoc.get_last_addresses
  def get_last_addresses
    required :auth_token
    required :type

    locations = []
    if params[:type] == 'billing'
      locations = current_patient.locations.where(is_bill_address: true).order("updated_at DESC").limit(2)
      render json: {success: true, location: locations.map{ |location| location.as_json}}
    elsif params[:type] == 'saved_address'
      locations = current_patient.locations.where.not(address_type: nil).order("updated_at DESC").limit(2)
      render json: {success: true, location: locations.map{ |location| location.as_json}}
    else
      render status: 422, json: {success: false, errors: 'Invalid type'}
    end
  end
  
  api :PUT, '/patients/maps/save_current_location', "Save current patient's location"
  param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  param_group :doctor_around_param, Api::V1::Docs::Patients::MapsDoc
  example Api::V1::Docs::Patients::MapsDoc.save_current_location_desc
  def save_current_location
    required :lat
    required :lng
    required :address
    if current_patient
      current_patient.save_current_location(params[:lat].to_f, params[:lng].to_f, params[:address])
      # find doctor and keep doctor's HOLD Status
      # puts "---------cal KeepHoldDoctorStatusWorker -----------"
      # KeepHoldDoctorStatusWorker.new.perform(current_patient.id)
    end
    # else
    #   puts "---go to TEMP ------"
    #   temp_patient = TempPatient.where(latitude: params[:lat].to_f, longitude: params[:lng].to_f).first
    #   if temp_patient.nil?
    #     temp_patient = TempPatient.new 
    #     temp_patient.save_location(params[:lat].to_f, params[:lng].to_f)
    #   end
    #   doctor_id = temp_patient.find_doctor_has_min_eta
    #   doctor = Doctor.find_by_id(doctor_id)
    #   if doctor
    #     doctor.update_attributes(is_hold: true)
    #     patient_hold = temp_patient.patient_hold_doctors.create(doctor_id: doctor_id, hold_at: Time.zone.now)
    #     puts "--------cal ReleaseDoctorWorker ---------"
    #     ReleaseDoctorWorker.perform_at(patient_hold.hold_at + 5.minutes, doctor_id, patient_hold.hold_at)
    #   end
    #   temp_patient.update_attributes(changed_at: Time.zone.now)
    # end

    render json: {success: true}
  end

  api :PUT, '/patients/maps/out_covarage_area', "Collect out coverage area"
  param_group :out_covarage_area_param, Api::V1::Docs::Patients::MapsDoc
  example Api::V1::Docs::Patients::MapsDoc.out_covarage_area_desc
  def out_covarage_area
    required :name
    required :email
    required :post_code

    existed_record = OutCoverageArea.find_by(patient_name: params[:name], patient_email: params[:email], post_code: params[:post_code])
    if existed_record.present?
      render status: 422, json: {success: false, errors: "You has already submit this info!"}
    else
      OutCoverageArea.create(patient_name: params[:name], patient_email: params[:email], post_code: params[:post_code])
      render status: 200, json: {success: true, message: "Thanks for your submission."}
    end
  end
end

