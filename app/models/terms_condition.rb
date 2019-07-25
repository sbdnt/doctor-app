class TermsCondition < ActiveRecord::Base
  validates :content, presence: true
end
