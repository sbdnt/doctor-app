class Api::V1::Patients::PatientsController < Api::V1::BaseApiController
  # before_action :api_authenticate_patient!
  def available_doctors
    current_patient = Patient.find(params[:id])
    render json: current_patient.get_available_etas
  end

  def get_etas_from_patient_to_doctor
    current_patient = Patient.find(params[:id])
    list_patient_doctors = current_patient.patient_doctors.joins(:doctor).where('doctors.status = ?',1)
    render json: list_patient_doctors.map {|pd| {id: pd.id, patient_id: pd.patient_id, doctor_id: pd.doctor_id, eta: "#{pd.eta} mins"}}
  end

  api :GET, '/patients/patients', "Get patient's profile"
  param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  example Api::V1::Docs::PatientsDoc.index
  def index
    # required :auth_token
    patient = Patient.find_by_auth_token(params[:auth_token])
    if patient.nil?
      render status: 401, json: {success: false, errors: "Unauthorized"}
    else
      credit_payment = {}
      paypal_payment = {}
      if patient.patient_credit_payments.count > 0
        credit_payment = {credit_payment: patient.patient_credit_payments.active.map{|payment| payment.as_json}}
      end
      if patient.patient_paypal_payments.count > 0
        paypal_payment = {paypal_payment: [patient.patient_paypal_payments.last.as_json] }
      end
      render status: 200, json: { success: true, patient_info: patient.as_json_common
                                  }.merge!(credit_payment).merge!(paypal_payment)
    end
  end

  api :GET, '/patients/patients/total_credits', "Get patient's credits"
  param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  example Api::V1::Docs::PatientsDoc.total_credits_desc
  def total_credits
    patient = Patient.find_by_auth_token(params[:auth_token])
    host = request.protocol + request.host_with_port
    res = patient.nil? ? {} : patient.as_json_total_credits({host: host})
    render status: 200, json: res
  end

  api :POST, '/patients/patients/:id/update_credits', "Update patient's credits"
  param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  example Api::V1::Docs::PatientsDoc.update_credits_desc
  def update_credits
    required :appointment_id
    
    patient = Patient.find_by_id(params[:id])
    host = request.protocol + request.host_with_port
    res = patient.nil? ? {} : patient.as_json_update_credits({host: host})
    render json: res
  end


  api :POST, '/patients/patients/update_paypal_access_token', "Update access_token of patient from paypal"
  param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  example Api::V1::Docs::PatientsDoc.update_paypal_access_token_desc
  def update_paypal_access_token
   
    patient = Patient.find_by_auth_token(params[:auth_token])
    host = request.protocol + request.host_with_port
    if params[:paypal_access_token].blank?
       res = {success: false, errors: 'Paypal access_token is not blank' }       
    elsif patient && patient.update_attributes(paypal_access_token: params[:paypal_access_token])
      res = {id: patient.id, success: true, message: 'Patient has updated the paypal access_token successfully.'}
    else
      res = {errors: 'Patient not found'}
    end    
    render json: res
  end

  api :PUT, '/patients/patients/update_profile', "Update patient's profile"
  param_group :patient_profile, Api::V1::Docs::PatientsDoc
  example Api::V1::Docs::PatientsDoc.update_profile
  def update_profile
    # required :auth_token

    #Params for update patient's base infos
    # required :fullname if params[:patient].present? && params[:patient][:fullname].present?
    # required :email if params[:patient].present? && params[:patient][:email].blank?
    # required :phone_number if params[:patient].present? && params[:patient][:phone_number].blank?

    #Params for update credit payment
    # required :cc_payment_id if params[:credit_payment].present? && params[:credit_payment][:cc_payment_id].blank?
    required :cc_num if params[:credit_payment].present? && params[:credit_payment][:cc_num].blank?
    required :expiry if params[:credit_payment].present? && params[:credit_payment][:expiry].blank?
    required :cvc if params[:credit_payment].present? && params[:credit_payment][:cvc].blank?
    required :cc_type if params[:credit_payment].present? && params[:credit_payment][:cc_type].blank?

    #Params for update paypal payment
    required :payment_id if params[:paypal_payment].present? && params[:paypal_payment][:payment_id].blank?
    required :paypal_email if params[:paypal_payment].present? && params[:paypal_payment][:paypal_email].blank?
    required :password if params[:paypal_payment].present? && params[:paypal_payment][:password].blank?

    patient = Patient.find_by_auth_token(params[:auth_token])
    if patient.nil?
      render status: 401, json: {success: false, errors: "Unauthorized"}
    else
      if patient_params.present?
        patient.fullname = params[:patient][:fullname] if params[:patient][:fullname].present?
        patient.email = params[:patient][:email] if params[:patient][:email].present?
        patient.phone_number = params[:patient][:phone_number] if params[:patient][:phone_number].present?
        if patient.save
          render status: 200, json: {success: true}
        else
          render status: 500, json: {success: false, errors: patient.errors.full_messages.first}
        end
      elsif paypal_payment_params.present?
        payment = PatientPaypalPayment.find_by_id(paypal_payment_params[:payment_id])
        puts "payment = #{payment.inspect}"
        if payment
          payment.paypal_email = paypal_payment_params[:paypal_email]
          payment.password_bcrypt = paypal_payment_params[:password]
          if payment.save
            render status: 200, json: {success: true}
          else
            puts payment.errors.inspect
            render status: 500, json: { success: false, errors: payment.errors.full_messages.first}
          end
        else
          render status: 422, json: {success: false, errors: "Paypal payment does not exist"}
        end
      elsif credit_payment_params.present?
        payment = PatientCreditPayment.find_by_id(credit_payment_params[:cc_payment_id])
        puts "payment = #{payment.inspect}"
        valid_type = %w(visa mastercard)
        if payment
          payment.cc_num = credit_payment_params[:cc_num]
          payment.expiry = credit_payment_params[:expiry]
          payment.cvc_bcrypt = credit_payment_params[:cvc]
          if valid_type.include?(credit_payment_params[:cc_type])
            payment.cc_type = credit_payment_params[:cc_type]
            if payment.save
              patient.set_inactive_old_cards(active_card_id: payment.id, cc_type: payment.cc_type)
              render status: 200, json: {success: true}
            else
              render status: 500, json: {success: false, errors: payment.errors.full_messages.first}
            end
          else
            render status: 422, json: {success: false, errors: "#{credit_payment_params[:cc_type]} is not a valid cc_type"}
          end
        else
          if valid_type.include?(credit_payment_params[:cc_type])
            patient_credit_card = PatientCreditPayment.find_or_initialize_by(cc_num: credit_payment_params[:cc_num])
            patient_credit_card.cc_num = credit_payment_params[:cc_num]
            patient_credit_card.expiry = credit_payment_params[:expiry]
            patient_credit_card.cvc_bcrypt = credit_payment_params[:cvc]
            patient_credit_card.cc_type = credit_payment_params[:cc_type]
            if patient_credit_card.save
              patient.set_inactive_old_cards(active_card_id: patient_credit_card.id, cc_type: patient_credit_card.cc_type)
              render status: 201, json: { success: true }
            else
              render status: 422, json: {success: false, errors: patient_credit_card.errors.full_messages.first}
            end
          else
            render status: 422, json: {success: false, errors: "#{credit_payment_params[:cc_type]} is not a valid cc_type"}
          end
        end
      else
        render status: 422, json: {success: false, errors: "Missing parameters"}
      end
    end
  end

  api :GET, '/patients/patients/:doctor_id/view_doctor_profile', "Get doctor's profile"
  param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  example Api::V1::Docs::PatientsDoc.view_doctor_profile_desc
  def view_doctor_profile
    doctor = Doctor.find_by_id(params[:doctor_id])
    host = request.protocol + request.host_with_port
    res = doctor.nil? ? {} : doctor.as_json_view_profile({host: host})
    render json: res
  end

  api :GET, '/patients/patients/:doctor_id/track_doctor', "Track location doctor"
  param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  example Api::V1::Docs::PatientsDoc.track_doctor_desc
  def track_doctor
    doctor = Doctor.find_by_id(params[:doctor_id])
    appointment = Appointment.find_by_patient_id_and_doctor_id(current_patient.id, doctor.id)
    appointment_start = self.get_appointment_start
    min_eta = appointment_start[:est_time]
    # min_eta = current_patient.get_min_eta.nil? ? 0 : current_patient.get_min_eta.second
    host = request.protocol + request.host_with_port
    res = doctor.nil? ? {} : doctor.as_json_track_doctor({host: host}).merge({eta: min_eta})
    render json: res
  end

  api! "Update patient's device token"
  param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  param :device_token, String, desc: "Patient's device_token", required: true
  param :platform, String, desc: "Device platform, value = ios/android", required: true
  example Api::V1::Docs::PatientsDoc.update_device_token
  def update_device_token
    required :device_token
    required :platform
    if current_patient.update(device_token: params[:device_token], platform: params[:platform])
      short_data_updated = { 
        uid: current_patient.id,
        device_token: current_patient.device_token,
        platform: current_patient.platform
      }
      render json: { patient: short_data_updated }, status: 200
    else
      render json: { errors: current_patient.errors.full_messages.first }, status: 422
    end
  end

  def patient_params
    if params[:patient].present?
      params.require(:patient).permit(:email, :password, :password_confirmation,
                                    :phone_number, :fb_id, :fb_token, :fullname,
                                    :terms_of_service, :over_18)
    end
  end

  def paypal_payment_params
    if params[:paypal_payment].present?
      params.require(:paypal_payment).permit(:payment_id, :paypal_email, :password, :password_hash)
    end
  end

  def credit_payment_params
    if params[:credit_payment].present?
      params.require(:credit_payment).permit!
    end
  end
end
