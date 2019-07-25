ActiveAdmin.register PatientDoctor do

  menu label: 'Doctor Availability with Patient', parent: 'Doctors'
  config.batch_actions = false
  config.filters = false
  config.paginate = false

  actions :all, except: [:show, :new, :edit, :destroy]

  index do
    render :partial => "active_admin/patient_doctors/index_page"
  end

  controller do
    def index
      index! do |format|

        params[:sort] ||= 'name'
        params[:sort_direction] ||= 'asc'
        @patient_doctor = PatientDoctor.new
        @doctors = Doctor.none
        @calculate_lat_lng = false

        if params[:patient_doctor].present?
          if params[:patient_doctor][:latitude].present? && params[:patient_doctor][:longitude].present?
            @calculate_lat_lng = true
            @patient = TempPatient.find_or_create_by(latitude: params[:patient_doctor][:latitude].to_f, longitude: params[:patient_doctor][:longitude].to_f)
            if @patient.present?
              if @patient.address.nil?
                patient_address = Geocoder.address([params[:patient_doctor][:latitude].to_f, params[:patient_doctor][:longitude].to_f])
                @patient.update_attributes(address: patient_address)
              end
              @doctors = Doctor.joins(:doctor_zones).where(status: Doctor.statuses['approved'], available: true).where('doctor_zones.zone_id = ?', @patient.zone_id)
            end
          else
            if params[:patient_doctor][:patient_id].present?
              @patient = Patient.find_by_id(params[:patient_doctor][:patient_id].to_i)
              if @patient.present?
                assigned_doctor_id = @patient.appointments.active.where.not(status: Appointment.statuses[:pending]).first.try(:doctor_id)
                @doctors = Doctor.joins(:doctor_zones).where(status: Doctor.statuses['approved'], available: true).where('doctor_zones.zone_id = ?', @patient.zone_id)
                @doctors = @doctors.where.not(id: assigned_doctor_id) if assigned_doctor_id.present?
              end
            end
          end
        end

        case params[:sort]
        when 'name'
          @doctors = @doctors.order( params[:sort] + ' ' + params[:sort_direction] )
        when 'available_time'
          @doctors = @doctors.sort_by{|d| d.next_available}
          @doctors = @doctors.reverse if params[:sort_direction] == 'desc'
        end

        params[:sort_direction] = params[:sort_direction] == 'asc' ? 'desc' : 'asc'        

        format.html
      end
    end
  end

end
