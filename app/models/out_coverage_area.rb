class OutCoverageArea < ActiveRecord::Base
  validates :patient_name, :patient_email, :post_code, presence: true
end
