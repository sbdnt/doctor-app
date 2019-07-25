class Voucher < ActiveRecord::Base
  validates :voucher_code, presence: true, length: { minimum: 10 }, uniqueness: true
  validates :amount, presence: true, :format => { :with => /\A\d+(?:\.\d{0,2})?\z/ }, :numericality => {:greater_than_or_equal => 0}
  validate :check_amount_value, if: proc{|v| v.is_percentage}

  def self.auto_generate_code(amount)
    voucher_code = SecureRandom.hex(6).upcase
    voucher_code = voucher_code[0..3] + '-' + voucher_code[4..7] + '-' + voucher_code[8..11]
    duplicated_voucher = Voucher.where(voucher_code: voucher_code)

    while duplicated_voucher.any? do
      voucher_code = SecureRandom.hex(6).upcase
      voucher_code = voucher_code[0..3] + '-' + voucher_code[4..7] + '-' + voucher_code[8..11]
      duplicated_voucher = Voucher.where(voucher_code: voucher_code)
    end

    Voucher.create({voucher_code: voucher_code, amount: amount})
  end

  def check_amount_value
    if self.amount > 100
      self.errors.add :amount, 'should be smaller than 100%'
    end
  end

  def check_valid_code(patient_id)
    patient = Patient.find_by_id(patient_id)

    if patient
      appointment = Appointment.find_by_patient_id_and_voucher_id(patient_id, self.id)

      if appointment.present?
        return false
      else
        return true
      end
    else
      return false
    end
  end
end
