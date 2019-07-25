ActiveAdmin.register ReferralSetting do

  menu parent: 'Vouchers'
  config.batch_actions = false

  actions :all, except: [:new, :destroy]
  permit_params :email_subject, :sms, :email, :facebook, :twitter

  index do
    selectable_column
    id_column
    column :email_subject
    column :sms
    column :email
    column :facebook
    column :twitter
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :email_subject
      row :sms
      row :email
      row :facebook
      row :twitter
    end
  end

  form do |f|
    f.inputs "" do
      f.input :email_subject
      f.input :sms, :input_html => { :rows => 6 }
      f.input :email, :input_html => { :rows => 6 }
      f.input :facebook, :input_html => { :rows => 6 }
      f.input :twitter, :input_html => { :rows => 6 }
    end
    f.actions
  end
end
