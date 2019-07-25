class Patients::LocationsController < ApplicationController
  layout "locations"
  def index
    london_latlng = [51.507351, -0.127758]
    if patient_signed_in?
      if params[:select_billing].present?
        # @locations = current_patient.locations.where(is_bill_address: true)
        @locations = current_patient.locations.where(is_bill_address: true).order("updated_at DESC").limit(2)
        @from_billing = true
        @from_edit_profile = true if params[:from_edit_profile].present?
        @payment_id = params[:payment] || ""
        @auth_token = current_patient.try(:auth_token)
        puts @auth_token.inspect

      else
        # @locations = current_patient.locations.where(is_bill_address: false)
        @locations = current_patient.locations.order("updated_at DESC").limit(2)
        @from_billing = false
        @from_edit_profile = false
        session[:patient_auth_token] = current_patient.try(:auth_token)
        puts session[:patient_auth_token]
      end
    else
      @locations = []
    end
  end

  # Author: Thanh
  def new
    @location = Location.new
  end

  # Author: Thanh
  def create
    @location = current_patient.locations.build(location_params)
    persisted_location = @location.check_exists_address(location_params)

    if !persisted_location && @location.save
      flash[:success] = "Your location was saved successfully!"
      redirect_to patient_view_profile_path
    else
      @exists_error = "This address is exists!" if persisted_location
      render 'new'
    end
  end

  # Author: Thanh
  def edit
    @location = Location.where(id: params[:id]).first
    unless @location
      flash[:warning] = "This location is not exists."
      redirect_to patient_view_profile_path and return
    end
  end

  # Author: Thanh
  def update
    @location = Location.where(id: params[:id]).first
    persisted_location = @location.check_exists_address(location_params)

    if (!persisted_location || (persisted_location && persisted_location.address_type == @location.address_type)) && @location.update(location_params)
      flash[:success] = "Your location was saved successfully!"
      redirect_to patient_view_profile_path
    else
      @exists_error = "This address is exists!" if persisted_location
      render 'edit'
    end
  end

  def create_billing_address
    if patient_signed_in?
      location = current_patient.locations.where(address: params[:address], is_current_billing: true, is_bill_address: true)
      unless location.present?
        geocode = Geocoder.coordinates(params[:address])
        lat = geocode[0]
        lng = geocode[1]
        current_patient.locations.create(address: params[:address], is_current_billing: true, is_bill_address: true, latitude: lat, longitude: lng)
      end
      puts "location = #{location.inspect}"
      render json: {success: true}
    end
  end

  private
  # Author: Thanh
  def location_params
    params.require(:location).permit(:address, :latitude, :longitude, :address_type, :is_bill_address)
  end
end