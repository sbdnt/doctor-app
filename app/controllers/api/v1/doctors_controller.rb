class Api::V1::DoctorsController < ActionController::Base
  def update_location
    current_doctor = Doctor.find_by_id(params[:id])
    current_doctor.update_location(params[:latitude], params[:longitude])
    render json: current_doctor
  end

  def get_current_location
    current_doctor = Doctor.find_by_id(params[:id])
    render json: {latitude: current_doctor.latitude, longitude: current_doctor.longitude}
  end
end
