class ReferralCode < Voucher
  has_many :referral_infos, class_name: "ReferralInfo", foreign_key: 'referral_id', dependent: :destroy
  belongs_to :patient, class_name: "Patient", foreign_key: 'sponsor_id'

  validates :voucher_code, presence: true

  after_initialize :generate_referral_code, if: proc{|r| r.voucher_code.nil? }

  def generate_referral_code
    generate_code = SecureRandom.urlsafe_base64(9)
    dup_referral_code = Voucher.where(voucher_code: generate_code)

    while dup_referral_code.any? do
      generate_code = SecureRandom.urlsafe_base64(9)
      dup_referral_code = Voucher.where(voucher_code: generate_code)
    end

    self.amount = GpdqSetting.find_by_name('Refer bonus').value.to_f
    self.voucher_code = generate_code
  end

  def create_credit_for_sponsor(appointment_id)
    sponsor_id = self.sponsor_id
    sponsor_bonus = GpdqSetting.find_by_name("Sponsor bonus").value.to_f || 10

    expired_date = Time.zone.now
    expired_period = GpdqSetting.find_by_name("Expired CS Credit").value.to_i
    time_unit = GpdqSetting.find_by_name("Expired CS Credit").time_unit

    case time_unit
    when 'day'
      expired_date = expired_date + expired_period.days
    when 'month'
      expired_date = expired_date + expired_period.months
    when 'year'
      expired_date = expired_date + expired_period.years
    end

    Credit.create( patient_id: sponsor_id, credit_number: sponsor_bonus, expired_date: expired_date, credit_type: Credit.credit_types[:Sponsor], appointment_id: appointment_id)

    sponsor_email = self.patient.try(:email)
    PatientMailer.referrer_bonus_email(sponsor_email, sponsor_bonus).deliver_now if sponsor_email.present?
  end
  # def check_valid_code(patient_id)
  #   patient = Patient.find_by_id(patient_id)
  #   sponsor = patient.referred_by

  #   if patient
  #     referral_info = ReferralInfo.find_by_referred_user_id(patientid)
  #     if referral_info.present? && ( referral_info.was_bonused || referral_info.referral_id != self.id )
  #       return false
  #     else
  #       if sponsor.present? && sponsor != self.sponsor_id
  #         return false
  #       end
  #       return true
  #     end
  #   else
  #     return false
  #   end
  # end
end