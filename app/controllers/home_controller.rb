class HomeController < ApplicationController
  # before_filter :check_for_authenticate

  def index
    render :layout => "landing_page"
  end

  def home
  end

  def after_landing_sign_up
    render :layout => false
  end

  def check_for_authenticate
    if !agency_signed_in? && !doctor_signed_in?
      authenticate_agency!
    end
  end

end
