class Patients::PaymentsController < ApplicationController
  layout "patient"
  before_action :authenticate_patient!
  def index
    # @credit_payment = PatientCreditPayment.new
    @from = params[:from] || ""
    @payment = PatientPaypalPayment.new
    @cc_payment = PatientCreditPayment.new
    @min_eta = current_patient.get_min_eta || []
    @current_apt_location = current_patient.locations.where(is_current: true).first
    @current_billing = current_patient.locations.where(is_current_billing: true).last
  end

  def create
    @min_eta = current_patient.get_min_eta || []
    puts "@min_eta = #{@min_eta.inspect}"
    apt_status = @min_eta.first.nil? ? 0 : 4
    assigned_time_at = @min_eta.first.nil? ? nil : Time.zone.now
    if params[:appointment].present?
      # apt = Appointment.new(appointment_params)
      voucher_used = Voucher.find_by_voucher_code(params[:appointment][:voucher_code])
      location_id = current_patient.locations.where(is_current: true).last.id
      apt = Appointment.new({ patient_id: current_patient.id, doctor_id: @min_eta.first,
                              status: apt_status, assigned_time_at: assigned_time_at,
                              voucher_id: voucher_used.try(:id), location_id: location_id
                            })
      if apt.save
        voucher_used.update_attributes(is_used: true, appointment_id: apt.id) if voucher_used.present?
      end

      puts params[:patient_paypal_payment].present?.inspect
      if params[:patient_paypal_payment].present?
        @payment = PatientPaypalPayment.new(patient_paypal_payment_params)
        @cc_payment = PatientCreditPayment.new
        begin
          @payment.validate!
        rescue
          @payment.errors.add(:paypal_email, @payment.errors.messages[:paypal_email]) unless @payment.errors.messages[:paypal_email].nil?
          @payment.errors.add(:password, @payment.errors.messages[:password]) unless @payment.errors.messages[:password].nil?
          render 'index' and return
        end
        @payment.password_bcrypt = params[:patient_paypal_payment][:password]
        puts "location = #{current_patient.locations.where(is_current_billing: true).last.inspect}"
        puts "location_id = #{current_patient.locations.where(is_current_billing: true).last.id.inspect}"
        @payment.location_id = current_patient.locations.where(is_current_billing: true).last.id
        if params[:save_for_furture] == 'yes'
          message = 'Your paypal account was saved successfully!'
        else
          message = 'Your paypal account was not saved!'
          @payment.patient_id = nil
        end
        if @payment.save
          flash[:notice] = message
          redirect_to patients_maps_path(:tab => params[:tab], :confirm => true)
        else
          render 'index' and return
        end
      else
        @payment = PatientPaypalPayment.new
        @cc_payment = PatientCreditPayment.new(patient_credit_payment_params)
        @cc_payment.cvc_bcrypt = params[:patient_credit_payment][:cvc]
        puts "location = #{current_patient.locations.where(is_current_billing: true).last.inspect}"
        puts "location_id = #{current_patient.locations.where(is_current_billing: true).last.id.inspect}"
        @cc_payment.location_id = current_patient.locations.where(is_current_billing: true).last.id
        puts "@cc_payment = #{@cc_payment.inspect}"
        if params[:save_for_furture] == 'yes'
          message = 'Your credit card info was saved successfully!'
        else
          message = 'Your credit card info was not saved!'
          @cc_payment.patient_id = nil
          @cc_payment.is_active = false
        end
        if @cc_payment.save
          current_patient.set_inactive_old_cards(active_card_id: @cc_payment.id, cc_type: @cc_payment.cc_type) if @cc_payment.patient_id
          flash[:notice] = message
          redirect_to patients_maps_path(:tab => params[:tab], :confirm => true)
        else
          render 'index'
        end
      end
    end
  end

  def edit_histories
    @payments = current_patient.patient_credit_payments.active
    @paypals = current_patient.patient_paypal_payments
  end

  def update
    if params[:patient_credit_payment].present?
      @cc_payment = PatientCreditPayment.find_by_id(params[:id])
      # @cc_payment.update_attributes(patient_credit_payment_params)
      @cc_payment.update(patient_credit_payment_params)
      @cc_payment.cvc_bcrypt = params[:patient_credit_payment][:cvc]
      @cc_payment.save
      redirect_to edit_histories_patients_payments_path(payment_tab: "credit")
    else
      @paypal_payment = PatientPaypalPayment.find_by_id(params[:id])
      @paypal_payment.paypal_email = params[:patient_paypal_payment][:paypal_email]
      @paypal_payment.password_bcrypt = params[:patient_paypal_payment][:password]
      @paypal_payment.save
      redirect_to edit_histories_patients_payments_path(payment_tab: "paypal")
    end
  end

  def edit
    # @payment = PatientPaypalPayment.find_by_id(params[:id]) || PatientPaypalPayment.new
    # @cc_payment = PatientCreditPayment.find_by_id(params[:id]) || PatientCreditPayment.new
    if params[:payment_tab] == 'credit'
      @cc_payment = PatientCreditPayment.find_by_id(params[:id])
      if @cc_payment.location_id.present?
        @current_billing = Location.find_by_id(@cc_payment.location_id)
      end
    else
      @payment = PatientPaypalPayment.find_by_id(params[:id])
      puts @payment.inspect
      if @payment.location_id.present?
        @current_billing = Location.find_by_id(@payment.location_id)
      end
    end
  end

  def apply_voucher
    puts @payment.inspect
    puts @cc_payment.inspect
    if params[:voucher_code].present?
      voucher = Voucher.where(voucher_code: params[:voucher_code]).first
      if voucher.present?
        if voucher.is_used == false
          render json: {success: true, voucher_code: voucher.voucher_code, message: "This voucher code was used successfully"}
        else
          render json: {success: false, message: "This voucher code already used!"}
        end
      else
        render json: {success: false, message: "This voucher code not found!"}
      end
    else
      render json: {success: false, message: "Voucher code can't be blank!"}
    end
  end

  # Author: Thanh
  def new
    @credit_card = PatientCreditPayment.new
    @paypal = PatientPaypalPayment.new
  end

  # Author: Thanh
  def edit
    if params[:method] == "credit_card"
      @credit_card = PatientCreditPayment.find(params[:id])
    end
    if params[:method] == "paypal"
      @paypal = PatientPaypalPayment.find(params[:id])
    end
  end

  # Author: Thanh
  def create_credit_card
    @credit_card = current_patient.patient_credit_payments.build(credit_card_params)
    @credit_card.cc_type = @credit_card.get_card_type
    if @credit_card.save
      @credit_card.encrypt_credit_info
      current_patient.set_inactive_old_cards(active_card_id: @credit_card.id, cc_type: @credit_card.cc_type)
      flash[:success] = 'Your credit card info was saved successfully!'
      redirect_to patient_view_profile_path
    else
      @paypal = PatientPaypalPayment.new
      render 'new', method: 'credit_card'
    end
  end

  # Author: Thanh
  def create_paypal
    @paypal = current_patient.patient_paypal_payments.build(paypal_params)
    if @paypal.save
      flash[:success] = 'Your paypal account was saved successfully!'
      redirect_to patient_view_profile_path
    else
      @credit_card = PatientCreditPayment.new
      render 'new', method: 'paypal'
    end
  end

  # Author: Thanh
  def update_paypal
    @paypal = PatientPaypalPayment.find(params[:id])
    if @paypal.update(paypal_params)
      flash[:success] = 'Your paypal account was updated successfully!'
      redirect_to patient_view_profile_path
    else
      render 'edit', method: 'paypal'
    end
  end

  # Author: Thanh
  def update_credit_card
    @credit_card = PatientCreditPayment.find(params[:id])
    @credit_card.cc_num = credit_card_params[:cc_num]
    @credit_card.cc_type = @credit_card.get_card_type
    if @credit_card.update(credit_card_params)
      @credit_card.encrypt_credit_info
      current_patient.set_inactive_old_cards(active_card_id: @credit_card.id, cc_type: @credit_card.cc_type)
      flash[:success] = 'Your paypal account was updated successfully!'
      redirect_to patient_view_profile_path
    else
      @paypal = current_patient.patient_paypal_payments.last
      render 'edit', method: "credit_card"
    end
  end

  private
  def patient_paypal_payment_params
    params.require(:patient_paypal_payment).permit(:patient_id, :paypal_email, :password, :password_hash)
  end

  def patient_credit_payment_params
    params.require(:patient_credit_payment).permit!
    # params.require(:patient_credit_payment).permit(:patient_id, :cc_type, :cc_num, :expiry, :cvc)
  end

  def appointment_params
    params.require(:appointment).permit(:patient_id, :doctor_id, :status, :assigned_time_at, :voucher_code)
  end

  def paypal_params
    params.require(:patient_paypal_payment).permit(:paypal_email, :password)
  end

  def credit_card_params
    params.require(:patient_credit_payment).permit(:cc_num, :expiry, :cvc, :bill_address, :lat_bill_address, :lng_bill_address)
  end

end
