ActiveAdmin.register SmsSystem do
  permit_params :patient_id, :doctor_id, :to, :originator, :message, :sent_via
  actions :all, :except => [:edit, :destroy]
  config.batch_actions = false

  index :download_links => false do
    selectable_column
    id_column
    column :patient_id
    column :doctor_id
    column :to
    column :originator
    column :message
    column :sent_via
    column :status
    column :reason
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs "SmsSystem" do
      # f.input :doctor, as: :select, collection: Doctor.all, include_blank: true
      # f.input :patient, as: :select, collection: Patient.all, include_blank: true
      f.input :to, input_html: {maxlength: 255}
      f.input :originator, input_html: {maxlength: 16}
      f.input :message, input_html: {maxlength: 255, rows: 3}
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :patient_id
      row :doctor_id
      row :to
      row :originator
      row :message
      row :sent_via
      row :status
      row :reason
      row :created_at
    end
  end
  
  controller do
    def new
      super
    end

    def create
      @sms = SmsSystem.new(permitted_params[:sms_system])
      res = @sms.class.send_sms(permitted_params[:sms_system].symbolize_keys)
      @sms.status = SmsSystem.statuses[res[:status]]
      @sms.reason = res[:reason] if res[:reason].present?
      @sms.sent_via = SmsSystem.sent_via["back_end"]
      if @sms.save
        redirect_to admin_sms_systems_path
      else
        render :new
      end
    end

    def permitted_params
      params.permit sms_system: [:to, :message, :originator, :patient_id, :doctor_id, :status, :reason, :sent_via]
    end
  end
end
