class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  def after_sign_in_path_for(resource)
    stored_location_for(resource) ||
      if resource.is_a?(Admin)
        admin_dashboard_path
      elsif resource.is_a?(Patient)
        patients_dashboards_path(:tab=>"yes")
      else
        home_path
      end
  end
  private

  def after_sign_out_path_for(resource_or_scope)
    case resource_or_scope.to_s

    when "agency"
      new_agency_session_path
    when "doctor"
      new_doctor_session_path
    when "patient"
      new_patient_session_path
    else
      home_path
    end
  end
end
