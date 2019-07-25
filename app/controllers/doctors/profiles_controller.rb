class Doctors::ProfilesController < ApplicationController
  before_filter :authenticate_doctor!
  def view
  end

  def job_history
  end

  def payment_history
  end

  def edit
    @doctor = current_doctor
  end

  def update
    @doctor = current_doctor
    if @doctor.update(doctor_params)
      # Sign in the doctor by passing validation in case their password changed
      sign_in @doctor, :bypass => true
      redirect_to edit_doctor_registration_path(@doctor)
    else
      render "edit"
    end
  end

  private

  def doctor_params
    # NOTE: Using `strong_parameters` gem
    params.required(:doctor).permit(:password, :password_confirmation)
  end

end