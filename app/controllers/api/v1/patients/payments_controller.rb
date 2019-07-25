class Api::V1::Patients::PaymentsController < Api::V1::BaseApiController
  api :POST, '/patients/payments/create_paypal_payment', "Appointment request for paypal"
  param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  param_group :paypal_payment_params, Api::V1::Docs::Patients::PaymentsDoc
  example Api::V1::Docs::Patients::PaymentsDoc.create_paypal_payment_decs
  def create_paypal_payment
    # required_raise_one :paypal_email if params[:paypal_payment].present? && params[:paypal_payment][:paypal_email].blank?
    # required_raise_one :password if params[:paypal_payment].present? && params[:paypal_payment][:password].blank? || (params[:paypal_payment].nil? && params[:credit_payment].present?)
    required_raise_one :authorization_code if params[:paypal_payment].present? && params[:paypal_payment][:authorization_code].blank? || params[:paypal_payment].blank?
      
    if params[:paypal_payment][:authorization_code].present?
      # payment = current_patient.patient_paypal_payments.find_or_initialize_by(authorization_code: paypal_payment_params[:authorization_code])
      # payment.password = paypal_payment_params[:password]
      res = PaypalPayment.get_refresh_token(paypal_payment_params[:authorization_code])
      if res["refresh_token"].present? && res["email"].present?
        payment = current_patient.patient_paypal_payments.find_or_initialize_by(refresh_token: res["refresh_token"])
        payment.refresh_token = res["refresh_token"]
        payment.paypal_email = res["email"]
        if payment.new_record?
          message = "Your paypal account was saved successfully!"
          status = 201
        else
          message = "Your paypal account was updated successfully!"
          status = 200
        end
        if payment.save
          render json: { success: true, message: message, paypal_payment: [current_patient.patient_paypal_payments.last.as_json] }, status: status
        else
          render json: { success: false, errors: payment.errors.full_messages.first }, status: :unprocessable_entity
        end
      else
        render json: { success: false, errors: "Invalid token" }, status: :unprocessable_entity
      end
    else
      render json: {errors: "should make valid params for paypal"}
    end
  end

  api :POST, '/patients/payments/create_credit_payment', "Appointment request for credit card"
  param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  param_group :credit_payment_params, Api::V1::Docs::Patients::PaymentsDoc
  example Api::V1::Docs::Patients::PaymentsDoc.create_credit_payment_desc
  def create_credit_payment
    required_raise_one :cc_type if params[:credit_payment].present? && params[:credit_payment][:cc_type].blank? || (params[:credit_payment].nil? && params[:paypal_payment].present?)
    required_raise_one :cc_num if params[:credit_payment].present? && params[:credit_payment][:cc_num].blank? || (params[:credit_payment].nil? && params[:paypal_payment].present?)
    required_raise_one :expiry if params[:credit_payment].present? && params[:credit_payment][:expiry].blank? || (params[:credit_payment].nil? && params[:paypal_payment].present?)
    required_raise_one :cvc if params[:credit_payment].present? && params[:credit_payment][:cvc].blank? || (params[:credit_payment].nil? && params[:paypal_payment].present?)

    @min_eta = current_patient.get_min_eta || []
    apt_status = @min_eta.first.nil? ? 0 : 4
    assigned_time_at = @min_eta.first.nil? ? nil : Time.zone.now

   
    apt = Appointment.new({ patient_id: current_patient.id, doctor_id: @min_eta.first,
                            status: apt_status, assigned_time_at: assigned_time_at#,
                            #voucher_id: voucher.try(:id)
                          })
    
    if params[:credit_payment].present?
      @cc_payment = current_patient.patient_credit_payments.new(credit_payment_params)

      # @cc_payment.cc_num = @cc_payment.send :encode, params[:credit_payment][:cc_num]
      @cc_payment.cvc = @cc_payment.send :encode, params[:credit_payment][:cvc]
      if params[:save_for_furture] == "yes"
        message = "Your credit card info was saved successfully!"
      else
        message = "Your credit card info was not saved!"
        @cc_payment.patient_id = nil
        @cc_payment.is_active = false
      end
      if @cc_payment.save
        current_patient.set_inactive_old_cards(active_card_id: @cc_payment.id, cc_type: @cc_payment.cc_type) if @cc_payment.patient_id
        cc_num_encoded = @cc_payment.send :encode, @cc_payment.cc_num
        @cc_payment.update_columns(cc_num: cc_num_encoded)
        render json: { success: true, message: message, credit_payment: current_patient.reload.patient_credit_payments.active.map { |payment| payment.as_json} }, status: :created
      else
        render json: { success: false, errors: @cc_payment.errors.full_messages.first }, status: :unprocessable_entity
      end
    else
      render json: {errors: "should make valid params for credit payment"}
    end
  end

  api :GET, '/patients/payments/billing_addresses', "Get patient's profile"
  param_group :base_group, Api::V1::Docs::Patients::SessionsDoc
  example Api::V1::Docs::Patients::PaymentsDoc.billing_addresses_desc
  def billing_addresses
    res = current_patient.locations.where(is_bill_address: true).order("created_at").map {|location|
      location.as_json
    }
    render json: res
  end


  private
  def paypal_payment_params
    params.require(:paypal_payment).permit(:patient_id, :paypal_email, :refresh_token, :authorization_code)
  end

  def credit_payment_params
    # params.require(:credit_payment).permit!
    params.require(:credit_payment).permit(:patient_id, :cc_type, :cc_num, :expiry, :cvc, :lat_bill_address, :lng_bill_address, :bill_address)
  end

  def appointment_params
    params.require(:appointment).permit(:patient_id, :doctor_id, :status, :assigned_time_at, :voucher_id)
  end


end
