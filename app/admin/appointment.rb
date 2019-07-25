ActiveAdmin.register Appointment do
  menu priority: 5
  config.batch_actions = false
  config.clear_action_items!
  # actions :all, :except => [:destroy]
  scope :live_appointments, :default => true do |apt|
    apt.live
  end
  scope :past_appointments do |apt|
    apt.complete
  end
  member_action :cancel_appointment, method: :put do
    resource.update_attributes(is_canceled: Appointment.is_canceleds[:canceled], booking_type: Appointment.booking_types[:bk_canceled], canceled_by_id: current_admin.id, canceled_by_type: current_admin.class.to_s)
    resource.set_unused_voucher_code
    redirect_to admin_appointments_path, notice: "Appointment was canceled successfully!"
  end
  member_action :auto_scheduling, method: :put do
    AssignDoctorWorker.new.perform(resource.id, true)
    redirect_to admin_appointments_path, notice: "Appointment was auto scheduling successfully!"
  end

  action_item :only => [:index] do |resource|
    link_to('New Appointment', new_resource_path(resource))
  end

  action_item :only => [:show] do |resource|
    if appointment.status == 'pending'
      link_to('Edit Appointment', edit_resource_path(resource))
    end
  end

  index :download_links => false do
    selectable_column
    id_column
    # column :id
    column :doctor, sortable: 'doctors.name' do |ap|
      if ap.try(:doctor).present?
        div("data-placement" => "top", "data-toggle" => "tooltip", :title => "Name : #{ap.try(:doctor).name} <br/>
                                                                              Tel: #{ap.try(:phone_number)} <br/>
                                                                              Agency: #{ap.try(:agency).try(:name).nil? ? "Blank" : ap.try(:agency).try(:name)}") do
          span ap.try(:doctor).name
        end
      end
    end
    column :patient, sortable: 'patients.try(:fullname)' do |ap|
      if ap.try(:patient).present?
        div("data-placement" => "top", "data-toggle" => "tooltip", :title => "Name : #{ap.try(:patient).name} <br/>
                                                                              Tel: #{ap.try(:patient).try(:phone_number)} <br/>
                                                                              Location: #{ap.try(:patient).try(:address)}") do
          span ap.try(:patient).name
        end
      end
    end
    column :agency, sortable: 'agencies.name'

    column 'Address' do |ap|
      ap.address
    end
    column "Assigned Time" do |ap|
      ap.try(:assigned_time_at).try(:strftime, "%b %d, %Y %H:%M")
    end
    column :start_at
    column :end_at
    column "Type" do |ap|
      ap.apm_type.gsub("_", " ").capitalize
    end
    column "Status" do |ap|
      ap.status.gsub("_", " ").capitalize
    end
    # column 'View Invoice' do |ap|
    #   ap.invoice.present? ? ( link_to 'View', admin_invoice_path(ap.invoice.id) ) : 'N/A'
    # end
    # column 'Create/Edit Invoice' do |ap|
    #   ap.invoice.present? ? ( link_to 'Edit', edit_admin_invoice_path(ap.invoice.id) ) : ( link_to 'Create', new_admin_invoice_path(appointment_id: ap.id) )
    # end
    column 'Rating' do |ap|
      if ap.try(:rating).present?
        div("style" => "width: 90px", "data-placement" => "top", "data-toggle" => "tooltip", :title => "#{strip_html(ap.try(:feedback))}") do
          ap.try(:rating).times do
            span image_tag asset_url("mid-star.png"), class: 'rating-image'
          end
        end
      end
    end
    column "PaymentStatus" do |ap|
      ap.payment_status.split("_").last.capitalize
    end
    column "Booking Type" do |ap|
      ap.booking_type.split("bk_").last.gsub("_", " ").capitalize
    end
    column 'Voucher code' do |ap|
      ap.voucher.voucher_code if ap.voucher
    end
    column 'Total Invoice' do |ap|
      number_to_currency(ap.invoice.try(:total_prices), precision: 2, unit: "£", separator: ".", delimiter: ",")
    end
    column :transport
    # actions
    column :actions do |resource|
      div(class: "table_actions") do
        # links = link_to I18n.t('active_admin.view'), resource_path(resource), class: "appointment-view"
        links = "".html_safe()
        if resource.pending? && resource.normal? && !resource.bk_canceled?
          links += link_to "Cancel", cancel_appointment_admin_appointment_path(resource), class: "btn btn-danger btn-appt-cancel", method: :put, data: { confirm: "This appointment will be canceled. Are you sure?" }
        end
        links += link_to "Delete", resource_path(resource), method: :delete, :data => { :confirm => 'Are you sure?' }
        if resource.judo_transactions.count > 0
          links += link_to('Transactions', resource_path(resource, transactions: true))
        end
        links += ""
      end
    end
  end
  filter :id, label: "Appointment Id", :as => :numeric
  filter :agency
  filter :patient, as: :select, collection: proc { Patient.order('fullname') }
  filter :doctor, as: :select, collection: proc { Doctor.order('name') }
  filter :start_at
  filter :end_at
  filter :apm_type, label: "Appointment Type", as: :select, :collection =>  Appointment.apm_types.map{|x| [x[0].to_s.upcase.gsub("_", " "), x[1]]}
  filter :status, as: :select, :collection =>  Appointment.modify_status.map{|x| [x[0].to_s.upcase.gsub("_", " "), x[1]]}

  show do
    panel "" do
      if params[:transactions].present?
        render partial: "active_admin/appointments/transactions", locals: {appointment: appointment}
      else
        render partial: "active_admin/appointments/details", locals: {appointment: appointment}
      end
    end
  end

  form do |f|
    f.inputs "Manual scheduling appointment" do
      if !f.object.new_record?
        f.input :patient_id, as: :hidden
        f.input :rating, as: :hidden
        f.input :is_canceled, as: :hidden, input_html: {value: 'normal'}
        f.input :doctor, as: :select, collection: Patient.find_by_id(f.object.patient_id).get_available_etas_for_appt, include_blank: false
        if Patient.find_by_id(f.object.patient_id).get_available_etas_for_appt.length == 0
          span "No available doctor found."
        end
        f.input :status, as: :radio, :label => "Status", :collection => Appointment.modify_status.keys.map{|a| [a.to_s.gsub("_", " ").capitalize, a]}
        f.input :booking_type, as: :select, :label => "Booking Type",
                :collection => Appointment.booking_types.keys.select{|n| n == :bk_manual_resheduled}.map{|a| [a.to_s.gsub("_", " ").capitalize, a]},
                input_html: {value: Appointment.booking_types[:bk_manual_resheduled]}, include_blank: false
      else
        f.input :patient_id, label: "Patient", as: :select, collection: Patient.all.map{|u| ["#{u.name}", u.id]}, include_blank: false
        f.input :start_at, as: :date_picker
        # f.input :end_at
        f.input :duration
        f.input :description
        f.input :rating
        f.input :feedback, label: "Feedback", input_html: {class: "txt_area"}
        f.input :status, as: :radio, :label => "Status", :collection => Appointment.modify_status.keys.map{|a| [a.to_s.gsub("_", " ").capitalize, a]}
        # f.input :status, as: :radio, :label => "Status", :collection => Appointment.modify_status.keys.select{|n| n == :pending}.map{|a| [a.to_s.gsub("_", " ").capitalize, a]}
      end
    end
    f.actions
  end

  controller do
    # def index
    #   @apointments = Appointment.first
    # end
    def update
      super do |format|
        format.html { redirect_to admin_appointments_path }
      end
    end

    def permitted_params
      params.permit appointment: [:doctor_id, :patient_id, :start_at, :end_at, :duration, :description, :status, :rating, :feedback, :booking_type, :is_canceled, :voucher_id]
      # params.require(:appointment).permit(:doctor_id, :patient_id, :start_at, :end_at, :duration, :description, :status, :rating, :feedback, :booking_type, :is_canceled, :voucher_id)
    end

    def scoped_collection
      # super.where(is_canceled: 0).includes(:doctor).includes(:patient).includes(:agency)
      super.includes(:doctor).includes(:patient).includes(:agency)
    end

  end

end
