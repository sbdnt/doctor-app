class GpdqPhone < ActiveRecord::Base
  validates :department, :phone_number, presence: true

  def as_json
    {
      uid: self.id,
      department: self.department,
      phone_number: self.phone_number
    }
  end
end
