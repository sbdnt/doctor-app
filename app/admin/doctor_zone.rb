ActiveAdmin.register DoctorZone do

  menu label: 'Doctor Availability with Zone', parent: 'Doctors'
  config.batch_actions = false
  config.filters = false
  config.paginate = false

  actions :all, except: [:show, :new, :edit, :destroy]

  index do
    render :partial => "active_admin/doctor_zones/index_page"
  end

  controller do
    def index
      index! do |format|
        params[:sort] ||= 'name'
        params[:sort_direction] ||= 'asc'
        @doctor_zone = DoctorZone.new
        @doctors = Doctor.where(status: Doctor.statuses['approved'], available: true)
        @zones = Zone.order('name')
        # @zone_list = @doctors.map(&:doctor_zones).flatten.map(&:zone).uniq.sort_by{|z| z.name}
        if params[:commit] == "Reload Zones"
          @doctors.each do |doctor|
            doctor.save_eta_with_zones
          end
        end

        case params[:sort]
        when 'name'
          @doctors = @doctors.order( params[:sort] + ' ' + params[:sort_direction] )

        when 'available_time'
          @doctors = @doctors.sort_by{|d| d.next_available}
          @doctors = @doctors.reverse if params[:sort_direction] == 'desc'
        end
        
        # @tracking_zones = params[:zone_ids].present? ? Zone.where(id: params[:zone_ids]).order_by_ids(params[:zone_ids]) : @zone_list.take(8)
        params[:sort_direction] = params[:sort_direction] == 'asc' ? 'desc' : 'asc'        

        format.html
      end
    end
  end
end
