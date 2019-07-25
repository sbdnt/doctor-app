class Element < ActiveRecord::Base
  belongs_to :category
  has_many :working_days, dependent: :destroy
  accepts_nested_attributes_for :working_days, allow_destroy: true

  INFORMATION = "Information"
  validates :name, :phone, presence: true
  validates :address, presence: true, if: proc{|e| e.category.present? && e.category.kind == INFORMATION}

  def as_json(options = {}) 
    {
      uid: self.id,
      name: self.name,
      phone: self.phone,
      address: self.address
    }
  end
end
