ActiveAdmin.register Patient do
  menu priority: 4, parent: 'Patients'
  config.batch_actions = false
  permit_params :email, :first_name, :last_name, :fullname, :avatar, :latitude, :longitude, :address, :zone_id, :phone_number
  index :download_links => false do
    selectable_column
    id_column
    column :email
    # column :first_name
    # column :last_name
    column :fullname
    column :avatar do |p|
      image_tag p.avatar.url, width: "50px", height: "50px"
    end
    column :phone_number
    column :address
    column :latitude
    column :longitude
    column :patient_zone
    column :auth_token
    column :created_at
    column :updated_at
    actions
  end

  filter :email
  # filter :first_name
  # filter :last_name
  filter :fullname
  filter :address
  filter :patient_zone

  form do |f|
    f.inputs "Patients" do
      f.input :email
      # f.input :first_name
      # f.input :last_name
      f.input :fullname
      f.input :avatar, :hint => "The format file is jpg/jpeg/gif/png"
      f.input :phone_number
      f.input :address
      f.input :zone_id, :collection => Zone.order('name'), :label_method => :name, :value_method => :id, :include_blank => false, input_html: {class: "zone-select2"}, as: :select
    end
    f.actions
  end

  show do
    attributes_table do
      row :email
      # row :first_name
      # row :last_name
      row :auth_token
      row :fullname
      row :avatar do |p|
        image_tag p.avatar.url, width: "50px", height: "50px"
      end
      row :phone_number
      row :address
      row :latitude
      row :longitude
      row :patient_zone
      row :device_token
      row :platform
      row :created_at
      row :updated_at
    end
  end

end
