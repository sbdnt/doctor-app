ActiveAdmin.register OutCoverageArea do
  menu priority: 3, parent: 'Zones'
  config.batch_actions = false
  # permit_params :name, :zone_id

  actions :all, :except => [:new, :edit, :destroy]

  index :download_links => false do
    selectable_column
    id_column
    column :patient_name 
    column :patient_email
    column :post_code
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs "SubZones" do
      f.input :zone, as: :select, collection: Zone.all, include_blank: false
      f.input :name
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :patient_name
      row :patient_email
      row :post_code
      row :created_at
    end
  end
end
