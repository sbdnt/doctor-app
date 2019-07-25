class Patients::AppointmentsController < ApplicationController
  layout "patient"
  before_action :authenticate_patient!

  def index
    params[:sort] ||= 'start_at'
    params[:sort_direction] ||= 'asc'
    # live_appointments = Appointment.where(patient_id: current_patient.id, is_canceled: 0).live
    live_appointments = Appointment.where(patient_id: current_patient.id).live
    if params[:query].present?
      live_appointments = live_appointments.where('name ilike ?',  "#{params[:query]}%")
    end
    @live_appointments = live_appointments.order( params[:sort] + ' ' + params[:sort_direction] )

    # past_appointments = Appointment.where(patient_id: current_patient.id, is_canceled: 0).complete
    past_appointments = Appointment.where(patient_id: current_patient.id).complete
    if params[:query].present?
      past_appointments = past_appointments.where('name ilike ?',  "#{params[:query]}%")
    end
    @past_appointments = past_appointments.order( params[:sort] + ' ' + params[:sort_direction] )

    params[:sort_direction] = params[:sort_direction] == 'asc' ? 'desc' : 'asc'
  end

  # Author: Thanh
  def new
    @appointment = Appointment.new
    @appointment_fee = Appointment.cal_appointment_fee(Time.zone.now)
  end

  # Author: Thanh
  def create
    @appointment = Appointment.new(appointment_params)
    @appointment.patient_id = current_patient.id

    set_payment_type()
    valid_voucher = check_valid_voucher()
    puts "@appointment = #{@appointment.inspect}"

    if valid_voucher[:status] && @appointment.save
      Voucher.find(@appointment.voucher_id).update(is_used: true) if @appointment.voucher_id
      @appointment.track_appointment_fees
      flash[:success] = "Appointment was created successfully!"
      redirect_to patient_view_profile_path
    else
      @appointment_fee = Appointment.cal_appointment_fee(Time.zone.now)
      @voucher_error_message = valid_voucher[:message] if valid_voucher
      render 'new'
    end
  end

  # Author: Thanh
  def track_doctor
    appointment = current_patient.appointments.where(id: params[:id]).where.not(doctor_id: nil).first
    if appointment && appointment.doctor
      @doctor = appointment.doctor
    else
      flash[:warning] = "Appointment is not assigned for doctor or not exist."
      redirect_to patient_view_profile_path
    end
  end

  private

  # Author: Thanh
  def appointment_params
    params.require(:appointment).permit(:lat, :lng, :address, :lat_bill_address, :lng_bill_address, :bill_address)
  end

  def set_payment_type
    payment = params[:payment].match(/^(?<paymentable_type>(PatientCreditPayment|PatientPaypalPayment)):(?<paymentable_id>\d+)$/)
    if payment
      @appointment.paymentable_type = payment[:paymentable_type]
      @appointment.paymentable_id = payment[:paymentable_id]
      set_billing_address(payment)
    end
  end

  def set_billing_address(payment)
    if payment[:paymentable_type] == 'PatientCreditPayment'
      if params[:same_bill_address] == 'true'
        credit_payment = PatientCreditPayment.find_by(id: payment[:paymentable_id])
        if credit_payment
          @appointment.bill_address = credit_payment.try(:bill_address)
          @appointment.lat_bill_address = credit_payment.try(:lat_bill_address).to_f
          @appointment.lng_bill_address = credit_payment.try(:lng_bill_address).to_f
        end
      end
    end
  end

  # Author: Thanh
  def check_valid_voucher
    if params[:voucher_code].present?
      voucher = Voucher.where(voucher_code: params[:voucher_code]).first
      if voucher
        if voucher.is_used?
          { status: false, message: "This voucher code already used!" }
        else
          @appointment.voucher_id = voucher.id
          { status: true }
        end
      else
        { status: false, message: "This voucher code not found!" }
      end
    else
      # Skip voucher
      { status: true }
    end
  end
end
