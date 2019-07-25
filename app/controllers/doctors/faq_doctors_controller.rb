class Doctors::FaqDoctorsController < ApplicationController
  def index
    @helps = FaqDoctor.where(is_published: true)
    render layout: "web_view"
  end
end
