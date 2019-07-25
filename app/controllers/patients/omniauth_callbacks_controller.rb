class Patients::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    if request.env["omniauth.params"]["sign_in_fb"] == "true"
      session["sign_in_fb"] = true
    else
      session["sign_in_fb"] = false
    end
    auth = request.env["omniauth.auth"]
    # Check patient existed? (sign up with fb)
    @patient = Patient.where(provider: auth.provider, fb_id: auth.uid).first
    # Check patient existed? (sign up normal with system)
    @patient_normal = Patient.where(email: auth.info.email, provider: nil).first
    # get referral_code if any?
    referral_code = request.env["omniauth.params"]["referral_code"] if request.env["omniauth.params"]
    if @patient.present? && @patient.persisted? || @patient_normal.present?
      # sign_in_and_redirect @patient #this will throw if @patient is not activated
      # set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
      sign_in @patient if @patient.present? && @patient.persisted?
      sign_in @patient_normal if @patient_normal.present?
      session["patient_existed"] = true
      puts "session = #{session['patient_existed'].inspect}"
      session["devise.facebook_data"] = auth
      redirect_to new_patients_facebook_path(referral_code: referral_code)
    else
      session["devise.facebook_data"] = auth
      session["patient_existed"] = false
      redirect_to new_patients_facebook_path(referral_code: referral_code)
    end
  end
end