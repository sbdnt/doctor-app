class AgencyMailer < ActionMailer::Base
  default from: "noreply@doctorapp.com"
  def validated_email(agency)
    @agency = agency
    mail(to: @agency.email, subject: 'Welcome to DoctorApp')
  end
  def welcome_email(agency)
    @agency = agency
    mail(to: @agency.email, subject: 'Welcome to DoctorApp')
  end
  def reject_agency(agency)
    @agency = agency
    mail(to: @agency.email, subject: 'Your account has been rejected!')
  end
end
