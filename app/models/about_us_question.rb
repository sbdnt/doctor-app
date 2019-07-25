class AboutUsQuestion < ActiveRecord::Base

  validates :content, presence: true
end
