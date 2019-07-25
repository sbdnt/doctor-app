ActiveAdmin.register AppointmentEvent do
  actions :index, :show

  # Permit params
  permit_params :appointment_id, :event_id, :patient_id, :doctor_id, :standard, :created_manual, :reason_code_id,
    :sms_message, :notification_message, :base_cost, :vat, :doctor_credit, :doctor_fine,
    :patient_credit, :patient_fee, :gpdq_income, :gpdq_cost, :free_text

  # Filters
  filter :appointment_id, as: :select, value_method: :id
  filter :event, as: :select, collection: proc { Event.order('name') }
  filter :reason_code, as: :select, collection: proc { ReasonCode.order('name') }
  filter :patient, as: :select, collection: proc { Patient.order('fullname') }
  filter :doctor, as: :select, collection: proc { Doctor.order('name') }
  filter :created_at
  filter :updated_at
  filter :doctor_credit
  filter :doctor_fine
  filter :patient_credit
  filter :patient_fee

  # Custom Views
  index do
    selectable_column
    column :id
    column "Appointment" do |appointment_event|
      link_to appointment_event.appointment_id, admin_appointment_path(appointment_event.appointment_id)
    end
    column :event
    column :patient
    column :doctor
    column :reason_code
    column :doctor_credit
    column :doctor_fine
    column :patient_credit
    column :patient_fee, label: "Patient cancelation fee"
    column :created_at
    column :updated_at
    actions defaults: false do |appointment_event|
      if appointment_event.require_manual_process?
        if appointment_event.is_processed?
          item "Edit", admin_appointment_path(appointment_event.appointment_id)
        else
          item "Process", admin_appointment_path(appointment_event.appointment_id)
        end
      else
        item "View", admin_appointment_event_path(appointment_event.id)
      end
    end
  end

  show do
    attributes_table do
      rows :id
      rows :appointment
      rows :event
      rows :reason_code
      rows :patient
      rows :doctor
      rows :created_at
      rows :updated_at
      rows :doctor_credit
      rows :doctor_fine
      rows :patient_credit
      rows :patient_fee
    end
  end

  # Custom Form
  form do |f|
    f.inputs do
      f.input :appointment, as: :select, collection: Appointment.order(id: :desc).pluck(:id)
      f.input :event
      f.input :patient
      f.input :doctor
      f.input :standard, label: "Standard event"
      f.input :created_manual
      f.input :reason_code
      f.input :sms_message
      f.input :notification_message
      f.input :base_cost
      f.input :vat, label: "VAT"
      if f.object.new_record?
        f.input :patient_credit
        f.input :patient_fee, label: "Patient cancelation fee"
      else
        f.input :patient_credit, input_html: { disabled: true }
        f.input :patient_fee, label: "Patient cancelation fee", input_html: { disabled: true }
      end
      f.input :doctor_fine
      f.input :doctor_credit
      f.input :gpdq_income
      f.input :gpdq_cost
      f.input :free_text, input_html: { rows: 4, cols: 50 }
    end
    f.actions do
      f.action :submit
      f.action :cancel
    end
  end

  # Override controller
  controller do
    def update
      params[:appointment_event].delete(:patient_fee)
      params[:appointment_event].delete(:patient_credit)
      update! # This method is supported by Inherited Resources gem 
    end
  end

  # Custom Actions
  collection_action :create_manual, method: :post do
    @appointment_event = AppointmentEvent.new(permitted_params[:appointment_event])
    respond_to do |format|
      @appointment_event.standard = @appointment_event.event.standard
      manual_process_event = ManualProcessEvent.where(event_id: @appointment_event.event.id, reason_code_id: @appointment_event.reason_code.try(:id)).first
      if manual_process_event
        @appointment_event.require_manual_process = manual_process_event.manual_process
        @appointment_event.is_processed = false
      end
      if @appointment_event.event.static_name == "Patient Cancellation"
        @appointment_event.patient_fee = @appointment_event.appointment.get_patient_fee
      end 

      if @appointment_event.save
        @appointment_event.track_patient_cs_credit()
        @appointment_event.send_sms_and_notification()
        format.js { render 'create_manual_success' }
      else
        format.js { render 'create_manual_unsuccess' }
      end
    end
  end

  member_action :update_manual, method: :patch do
    params[:appointment_event].delete(:patient_fee)
    params[:appointment_event].delete(:patient_credit)
    @appointment_event = AppointmentEvent.find(params[:id])
    @appointment_event.is_processed = true
    respond_to do |format|
      if @appointment_event.update(permitted_params[:appointment_event])
        format.js { render 'update_manual_success' }
      else
        format.js { render 'update_manual_unsuccess' }
      end
    end
  end
end
