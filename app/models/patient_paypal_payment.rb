require 'bcrypt'
class PatientPaypalPayment < ActiveRecord::Base
  include BCrypt

  #Relations
  belongs_to :location
  belongs_to :patient
  has_many :appointments, as: :paymentable

  # Validations
  validates :paypal_email, presence: true
  validate  :email_regex
  validates :refresh_token, presence: true
  # validates :password, presence: true
  # validates :location_id, presence: true
  # has_secure_password

  # validate :password_present, :if => proc{ |p| p.password.blank?}

  # def password_bcrypt
  #   @password ||= Password.new(password_hash)
  # end

  # def password_bcrypt=(new_password)
  #   if new_password.blank?

  #   else
  #     @password = Password.create(new_password)
  #     self.password = @password
  #     self.password_hash = @password
  #   end
  # end

  # Author: Thanh
  def password=(pwd)
    if pwd.present?
      pass = Password.create(pwd)
      self[:password] = pass
      self[:password_hash] = pass
    else
      self[:password] = self[:password_hash] = nil
    end
  end

  def email_regex
    if paypal_email.present? and not paypal_email.match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/)
      errors.add :paypal_email, "is not valid format"
    end
  end

  def as_json
  {
    uid:          self.id,
    paypal_email: self.try(:paypal_email),
    paymentable_type: self.class.name
  }
  end

end
