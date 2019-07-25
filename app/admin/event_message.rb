ActiveAdmin.register EventMessage do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  
  # Permit params
  permit_params :doctor_sms, :doctor_push, 
  :patient_sms, :patient_push, :patient_push_in_app, :doctor_push_in_app

  filter :event, as: :select, collection: proc { Event.order('name') }
  filter :reason_code, as: :select, collection: proc { ReasonCode.order('name') }
  filter :doctor_sms
  filter :doctor_push
  filter :doctor_push_in_app
  filter :patient_sms
  filter :patient_push
  filter :patient_push_in_app
  filter :created_at
  filter :updated_at

  # Custom Views
  index do
    column :id
    column :event
    column :reason_code
    column :doctor_sms
    column :doctor_push
    column :doctor_push_in_app
    column :patient_sms
    column :patient_push
    column :patient_push_in_app
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :event
      row :reason_code
      row :doctor_sms
      row :doctor_push
      row :doctor_push_in_app
      row :patient_sms
      row :patient_push
      row :patient_push_in_app
      row :created_at
      row :updated_at
    end
  end

  # Custom Form
  form do |f|
    f.inputs do
      f.input :event, input_html: { disabled: true }
      f.input :reason_code, input_html: { disabled: true }
      f.input :doctor_sms
      f.input :doctor_push
      f.input :doctor_push_in_app
      f.input :patient_sms
      f.input :patient_push
      f.input :patient_push_in_app
    end
    f.actions do
      f.action :submit
      f.action :cancel
    end
  end
end