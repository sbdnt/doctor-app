class GpdqEmail < ActiveRecord::Base
  validates :department, :email, presence: true

  def as_json
    {
      uid: self.id,
      department: self.department,
      email: self.email
    }
  end
end
