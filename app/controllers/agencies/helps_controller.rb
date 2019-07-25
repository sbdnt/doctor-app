class Agencies::HelpsController < ApplicationController
  def index
    params[:sort] ||= 'title'
    params[:sort_direction] ||= 'asc'
    helps = Help.all
    if params[:query].present?
      helps = helps.where('name ilike ?',  "#{params[:query]}%")
    end
    @helps = helps.order( params[:sort] + ' ' + params[:sort_direction] )

    params[:sort_direction] = params[:sort_direction] == 'asc' ? 'desc' : 'asc'
  end
  def show
    @help = Help.find_by_id params[:id]
  end
end
