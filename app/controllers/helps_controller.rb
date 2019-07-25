class HelpsController < ApplicationController
  def index
    @helps = Help.where(is_published: true)
  end

  def index_mobile
    @helps = Help.where(is_published: true)
    render :layout => "mobile"
  end

  def patient_faq
    @helps = Help.where(is_published: true)
    render layout: "web_view"
  end
end
