class PatientMailer < ApplicationMailer
  default from: "noreply@doctorapp.com"

  def forgot_password(patient_id, password)
    patient = Patient.find(patient_id)
    @password = password
    mail(to: patient.email, subject: '[Doctor App] Forgot password.')
  end

  def referred_user_bonus_email(email, voucher_code)
    @voucher_code = voucher_code

    subject = '[GPDQ] You was referred successfully!'
    mail(to: email, subject: subject)
  end

  def referrer_bonus_email(email, bonus_amount)
    @bonus_amount = bonus_amount

    subject = "[GPDQ] You get refer bonus from your friend's first booking!"
    mail(to: email, subject: subject)
  end
end
