class Patients::DashboardsController < Patients::MapsController
  #layout "patient"
  def index
    super if patient_signed_in?
  end
end
