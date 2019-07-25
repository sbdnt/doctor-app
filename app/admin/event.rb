ActiveAdmin.register Event do
  actions :index, :show, :edit, :update

  config.batch_actions = false

  # Permit params
  permit_params :name_for_push

  index do
    column :id
    column :name
    column :event_category
    column :standard
    column :created_via_back_end
    column :created_via_app
    column :doctor_sms
    column :doctor_push
    column :patient_sms
    column :patient_push
    column :in_app_alert
    column :name_for_push
    column :created_at
    column :updated_at
    actions
  end
end
