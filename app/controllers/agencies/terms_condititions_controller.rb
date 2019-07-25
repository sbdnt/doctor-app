class Agencies::TermsCondititionsController < ApplicationController

  def index
    @tc = TermsCondition.first
  end

  def show
    @tc = TermsCondition.find_by_id params[:id]
  end
end
