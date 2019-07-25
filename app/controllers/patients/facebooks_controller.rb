class Patients::FacebooksController < ApplicationController

  def new
    @patient = Patient.new
    @from_fb_sign_in = session["sign_in_fb"]
    auth = session["devise.facebook_data"]
    # puts "auth = #{auth.inspect}"
    # puts "auth['info']['email'] = #{auth['info']['email'].inspect}"
    @patient_info = auth['info']
    # puts "session = #{session['patient_existed'].inspect}"
    @patient_existed = session["patient_existed"]
    @current_patient = current_patient
    # puts "@current_patient = #{@current_patient.inspect}"
    @tc = TermsCondition.first
    if params[:referral_code].present?
      @referred_by = ReferralCode.find_by_voucher_code(params[:referral_code]).try(:sponsor_id)
    end
  end

  def create
    # puts "create patient facebook"
    # puts "session = #{session["devise.facebook_data"].inspect}"
    if session["devise.facebook_data"].present?
      @tc = TermsCondition.first
      auth = session["devise.facebook_data"]
      @from_fb_sign_in = session["sign_in_fb"]
      @patient = Patient.where( email: auth['info']['email'] ).first
      @patient_info = auth['info']

      # puts "params[:patient] = #{params[:patient].inspect}"

      if @patient.present? && @patient.persisted?
          if @patient.phone_number.present? && @patient.phone_number != params[:patient][:phone_number]

          end
      else
        create_params = patient_params.merge( provider: auth['provider'], fb_id: auth['uid'],
                                              fullname: auth['info']['first_name'].nil? && auth['info']['last_name'].nil? ? params[:patient][:fullname] : "#{auth['info']['first_name']} #{auth['info']['last_name']}",
                                              email: auth['info']['email'].nil? ? params[:patient][:email] : auth['info']['email'],
                                              password: Devise.friendly_token[0,20])
        puts "create_params = #{create_params.inspect}"
        @patient = Patient.new(create_params)
        if @patient.save
          session["devise.facebook_data"] = ''
          flash[:notice] = "Your account has been created successfully."
          sign_in @patient, :bypass => true
          session.delete(:sign_in_fb)
          unless session[:not_logged_location_id].nil?
            location = Location.find_by_id(session[:not_logged_location_id].to_i)
            location.update_attributes(patient_id: @patient.id, is_current: true)
            @patient.update_attributes(:address => location.address)
          end
          session.delete :not_logged_address
          session.delete :not_logged_address
          session.delete :not_logged_location_id
          redirect_to patients_maps_path(:tab => "yes")
        else
          render 'new'
        end
      end
    else
      flash[:errors] = "There was an error. Please log in again."
      redirect_to new_patient_session_path
    end
  end

  private

  def patient_params
    params.required(:patient).permit(:address, :zone_id, :phone_number, :email, :over_18, :terms_of_service, :first_name, :last_name, :fullname, :referred_by)
  end

end