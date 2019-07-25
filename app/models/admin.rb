class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable

  has_many :cancelled_appointments, as: :canceled_by, class_name: "Appointment"

  def admin?
    self.role == "admin"
  end
end
