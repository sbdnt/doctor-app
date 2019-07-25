class Patients::ProfilesController < ApplicationController
  before_filter :authenticate_patient!
  layout "patient"

  # Author: Thanh
  # Updated_by: Thai 09/18/2015
  def view
    # @last_saved_addresses = current_patient.locations.order(updated_at: :desc).limit(2)
    @last_saved_addresses = current_patient.locations.where.not(address_type: nil).order(updated_at: :desc).limit(2)
    @credit_cards = PatientCreditPayment.where(patient_id: current_patient.id)
    @paypal = PatientPaypalPayment.where(patient_id: current_patient.id).order(updated_at: :desc).first
  end

  def appoinment_history
  end

  def payment_history
  end

  def edit
    @patient = current_patient
  end

  # Author: Thanh
  def update
    @patient = current_patient
    if @patient.update_with_password(patient_params)
      flash[:success] = "Your new password is updated successfully."
      # Sign in the patient by passing validation in case their password changed
      sign_in @patient, :bypass => true
      redirect_to edit_patient_registration_path
    else
      render "edit"
    end
  end

  private

  # Author: Thanh
  def patient_params
    params.required(:patient).permit(:password, :current_password)
  end

end