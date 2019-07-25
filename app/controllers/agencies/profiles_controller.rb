class Agencies::ProfilesController < ApplicationController
  before_filter :authenticate_agency!

  def edit
    @agency = current_agency
  end

  def update
    @agency = current_agency
    if @agency.update(agency_params)
      # Sign in the agency by passing validation in case their password changed
      sign_in @agency, :bypass => true
      redirect_to edit_agency_registration_path(@agency)
    else
      render "edit"
    end
  end

  private

  def agency_params
    # NOTE: Using `strong_parameters` gem
    params.required(:agency).permit(:password, :password_confirmation)
  end
end