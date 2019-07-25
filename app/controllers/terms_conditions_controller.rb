class TermsConditionsController < ApplicationController
  def index
    @terms = TermsCondition.first
  end

  def index_mobile
    @terms = TermsCondition.first
    render :layout => "mobile"
  end
end
