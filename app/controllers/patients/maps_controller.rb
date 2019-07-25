class Patients::MapsController < ApplicationController
  layout :set_layout#, except: :edit_locations
  #layout "locations", except: [:index, :show_make_request, :make_appointment, :view_doctor, :life_threatening, :warning]
  def index
    #Set default location
    london_latlng = [51.507351, -0.127758]
    if patient_signed_in?
      if current_patient.get_min_eta.present? && current_patient.get_min_eta.third.present? && current_patient.get_min_eta.third >= Time.zone.now
        @arrived_time = current_patient.get_min_eta.third.try(:strftime, "%H:%M")
      else
        @arrived_time = ""
      end
      @doctors = current_patient.get_available_etas
      if @doctors.blank?
        puts "INDEX 1"
        @doctors = [Doctor.first]
        @markers = Gmaps4rails.build_markers(@doctors) do |doctor, marker|
          marker.lat london_latlng.first
          marker.lng london_latlng.last
          marker.json({:id => '' })
          marker.picture({
           'url' => '',#"/assets/doctor_marker.png",
           'width' =>  32,
           'height' => 32})
        end

      else
        puts "INDEX 2"
        @markers = Gmaps4rails.build_markers(@doctors) do |doctor, marker|
          marker.lat doctor[:latitude]
          marker.lng doctor[:longitude]
          marker.json({:id => doctor[:id] })
          marker.picture({
           "url" => "/assets/doctor_marker.png",
           "width" =>  32,
           "height" => 32})
        end
      end
      @min_eta = current_patient.get_min_eta || []
      @current_location = current_patient#.locations.order("updated_at DESC").first
      puts @current_location.inspect
      @doctor_id = @min_eta.first
      @status = @min_eta.last
    else
      @doctors = [Doctor.first]
      # temp_patient = TempPatient.where(latitude: london_latlng.first, longitude: london_latlng.last).first
      # if temp_patient.nil?
      #   temp_patient = TempPatient.new 
      #   temp_patient.save_location(london_latlng.first, london_latlng.last)
      # end
      # @doctors = temp_patient.find_doctor_around(london_latlng.first, london_latlng.last)
      @markers = Gmaps4rails.build_markers(@doctors) do |doctor, marker|
        marker.lat london_latlng.first
        marker.lng london_latlng.last
        marker.json({:id => "" })
        marker.picture({
         "url" => "",#"/assets/doctor_marker.png",
         "width" =>  32,
         "height" => 32})
      end
    end
    gon.markers = @markers
  end

  def show_make_request
  end

  def make_appointment
    unlocked_params = ActiveSupport::HashWithIndifferentAccess.new(params)
    @arrived_time = current_patient.get_min_eta.third.nil? ? nil : current_patient.get_min_eta.third.try(:strftime, "%H:%M")
    Appointment.create unlocked_params[:appointment]

  end

  def update_location
    geocode = Geocoder.coordinates(params[:location][:address])
    lat = geocode[0]
    lng = geocode[1]
    address_type = 'home'
    if patient_signed_in?
      current_patient.save_address(params[:location][:is_current_billing], params[:location][:address], lat, lng, address_type)
      session.delete :not_logged_address
    else
      session[:not_logged_address] = params[:location][:address]
      location = Location.create(:address => params[:location][:address], latitude: lat, longitude: lng, address_type: address_type)
      session[:not_logged_location_id] = location.id
      session[:lat_lng] = [location.latitude, location.longitude]
    end
    #session[:set_location] = true
    # if params[:location][:is_current_billing] == 'true'
    #   if params[:location][:from_edit_profile] == 'true'
    #     redirect_to edit_patients_payment_path(params[:payment], payment_tab: params[:tab], back: true)
    #   else
    #     redirect_to patients_payments_path(payment_tab: params[:tab], back: true)
    #   end
    # elsif params[:location][:next_step] == 'true'
    #   redirect_to life_threatening_patients_maps_path
    # else
    #   redirect_to patients_maps_path(:tab => params[:tab], :confirm => true)
    # end
  end

  def view_doctor
    @doctor = Doctor.find_by_id(params[:doctor_id])
    @min_eta = current_patient.get_min_eta || []
    @doctors = current_patient.get_available_etas
    @markers = Gmaps4rails.build_markers(@doctors) do |doctor, marker|
      if doctor[:id] == params[:doctor_id].to_i
        marker.lat doctor[:latitude]
        marker.lng doctor[:longitude]
        marker.json({:id => doctor[:id] })
        marker.picture({
         "url" => "/assets/doctor_marker.png",
         "width" =>  32,
         "height" => 32})
      end
    end
  end

  def find_and_show_doctor_around
    min_eta = 0
    if current_patient
      doctors = current_patient.find_doctor_around(params[:lat].to_f, params[:lng].to_f, params[:address], params[:range])
      # Find patient to get new data
      patient = Patient.find current_patient.id 
      if patient.get_min_eta.present? && patient.get_min_eta.second.present?
        min_eta = patient.get_min_eta.second
      end
    else
      temp_patient = TempPatient.where(latitude: params[:lat].to_f, longitude: params[:lng].to_f).first
      temp_patient = TempPatient.new if temp_patient.nil?
      doctors = temp_patient.find_doctor_around(params[:lat].to_f, params[:lng].to_f, params[:address], params[:range])
      min_eta = temp_patient.get_min_eta
    end
    @markers = Gmaps4rails.build_markers(doctors) do |doctor, marker|
      marker.lat doctor[:latitude]
      marker.lng doctor[:longitude]
      marker.json({:id => doctor[:id] })
      marker.picture({
       "url" => "/assets/doctor_marker.png",
       "width" =>  32,
       "height" => 32})

      puts "marker = #{marker.inspect}"
    end

    puts "@markers = #{@markers.inspect}"
    render json: {doctor_infos: doctors, min_eta: min_eta, markers: @markers}
  end

  def life_threatening
  end

  def warning
  end

  private

  def set_layout
    case action_name
    when "show_make_request", "life_threatening", "warning"
      "patient"
    else
      "map_layout"
    end
  end
end
