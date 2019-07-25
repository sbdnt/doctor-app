class DoctorMailer < ApplicationMailer
  default from: "noreply@doctorapp.com"

  def approved_doctor(doctor)
    @doctor = doctor
    mail(to: @doctor.email, subject: 'Welcome to DoctorApp')
  end
  def reject_doctor(doctor)
    @doctor = doctor
    mail(to: @doctor.email, subject: 'Your account has been rejected!')
  end

  def notify_assign_appointment(doctor)
    @doctor = doctor
    mail(to: @doctor.email, subject: 'Assignment Appoinment')
  end

  def forgot_password(doctor_id, new_password)
    doctor = Doctor.find(doctor_id)
    @new_password = new_password
    mail(to: doctor.email, subject: '[Doctor App] Forgot password.')
  end
end
