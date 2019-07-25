class DoctorsController < ApplicationController

  def index
    params[:sort] ||= 'name'
    params[:sort_direction] ||= 'asc'
    doctor_list = Doctor.where(agency_id: current_agency.id)
    if params[:query].present?
      doctor_list = doctor_list.where('name ilike ?',  "#{params[:query]}%")
    end
    @doctor_list = doctor_list.order( params[:sort] + ' ' + params[:sort_direction] )

    params[:sort_direction] = params[:sort_direction] == 'asc' ? 'desc' : 'asc'
  end

  def edit
    @doctor = Doctor.find_by_id( params[:id] )
  end

  def update
    @doctor = Doctor.find_by_id( params[:id] )
    if @doctor.update(doctor_params)
      flash[:notice] = 'Profile saved successfully!'
      redirect_to action: :index
    else
      render action: :edit
    end
  end

  def destroy
    @doctor = Doctor.find_by_id( params[:id] )
    #need to be sure deleting doctor won't affect on payment or booking records
    if @doctor.destroy!
      flash[:notice] = 'Doctor deleted successfully!'
    else
      flash[:error] = 'Can not delete this doctor now. Please try it later!'
    end
    redirect_to action: :index
  end

  private
  def doctor_params
    params.require(:doctor).permit(:email, :name, :first_name, :last_name, :description, :role, :phone_number, :phone_landline,
                                   :avatar, :avatar_cache, :gmc_cert, :gmc_cert_exp,
                                   :gmc_cert_cache, :dbs_cert, :dbs_cert_exp,:dbs_cert_cache,
                                   :mdu_mps_cert, :mdu_mps_cert_exp, :mdu_mps_cert_cache,
                                   :passport, :passport_cache, :default_start_location,
                                   :last_appraisal_summary, :last_appraisal_summary_exp,
                                   :last_appraisal_summary_cache, :reference_gp, :status,
                                   :reference_gp_cache, :hepatitis_b_status, :agency_id,
                                   :hepatitis_b_status_exp, :hepatitis_b_status_cache,
                                   :child_protection_cert, :child_protection_cert_exp,
                                   :child_protection_cert_cache, :adult_safeguarding_cert,
                                   :adult_safeguarding_cert_exp, :adult_safeguarding_cert_cache,
                                   :last_schedule_update,
                                   doctor_zones_attributes: [:zone_id, :doctor_id, :eta, :_destroy, :id])

  end
end