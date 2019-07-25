require 'bcrypt'
class PatientCreditPayment < ActiveRecord::Base
  include BCrypt

  # Scopes
  # default_scope { where(is_active: true).where.not(cc_type: 0) }
  scope :active, -> { where(is_active: true).where.not(cc_type: 0) }

  # Relations
  belongs_to :patient
  has_many :appointments, as: :paymentable

  CC_TYPE = %w(visa mastercard)
  # Validations
  validates :cc_num, :expiry, :cvc, :lat_bill_address, :lng_bill_address, :bill_address, presence: true
  validates :patient_id, presence: true, on: :update
  validates :cc_type, :inclusion => {:in => CC_TYPE}
  # validates :cc_num, format: { with: /^4[0-9]{12}(?:[0-9]{3})?$/,
  #   message: "is not correct format of visa card" }, if: "cc_type == 'visa'"
  # validates :cc_num, format: { with: /^5[1-5][0-9]{14}$/,
  #   message: "is not correct format of master card" }, if: "cc_type == 'mastercard'"
  validate :cc_num_format
  validate :expire_date

  enum cc_type: { visa: 1, mastercard: 2}


  # Author: Thanh
  def cc_num_format
    case cc_type
    when "visa"
      errors.add(:credit_card_number, "is invalid.") unless cc_num.gsub(/\s/, "").match(/^4[0-9]{12}(?:[0-9]{3})?$/)
    when "mastercard"
      errors.add(:credit_card_number, "is invalid.") unless cc_num.gsub(/\s/, "").match(/^5[1-5][0-9]{14}$/)
    end
  end

  # Author: Thanh
  def get_card_type
    return "visa" if cc_num.gsub(/\s/, "").match(/^4[0-9]{12}(?:[0-9]{3})?$/)
    return "mastercard" if cc_num.gsub(/\s/, "").match(/^5[1-5][0-9]{14}$/)
  end

  # Author: Thanh
  def expire_date
    begin
      errors.add(:expire_date, "must be a date in future.") if expiry.present? && expiry.remove!("\s").to_date.end_of_month < Time.zone.now
    rescue ArgumentError => e
      errors.add(:expire_date, "must be a valid date.")
    end
  end

  def cvc_bcrypt
    @cvc ||= Password.new(cvc)
  end

  def cvc_bcrypt=(cvc)
    @cvc = Password.create(cvc)
    self.cvc = @cvc
  end

  def masking_credit_number
    cc = decode(cc_num).nil? ? cc_num : decode(cc_num)
    cc[0, 4] + 'x' * (cc.size - 8) + cc[-4, 4] if cc
  end

  def as_json
    {
      uid:     id,
      cc_num:  masking_credit_number,
      cc_num_full: cc_num_decode,
      cc_type: self.try(:cc_type),
      paymentable_type: self.class.name,
      lat_bill_address: lat_bill_address,
      lng_bill_address: lng_bill_address,
      bill_address: bill_address
    }
  end

  # Author: Thanh
  def encrypt_credit_info
    cc_num_encoded = encode(self.cc_num.gsub(/\s/, ""))
    self.update_columns(cc_num: cc_num_encoded)
    cvc_encoded = encode(self.cvc)
    self.update_columns(cvc: cvc_encoded)
  end

  # Author: Thanh
  def cc_num_decode
    decode(cc_num)
  end

  private
  def encode(string_to_encrypt)
    encrypted_value = Encryptor.encrypt(string_to_encrypt, :key => Rails.application.secrets.secret_key, :iv => Rails.application.secrets.iv, :salt => Rails.application.secrets.salt)
    encoded = Base64.encode64(encrypted_value).encode('utf-8')
  end

  def decode(string_to_decrypt)
    decode = Base64.decode64 string_to_decrypt.encode('ascii-8bit')
    begin
      decoded = Encryptor.decrypt(decode, :key => Rails.application.secrets.secret_key, :iv => Rails.application.secrets.iv, :salt => Rails.application.secrets.salt)
    rescue
      nil
    end
  end
end
