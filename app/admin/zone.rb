ActiveAdmin.register Zone do
  menu priority: 0, parent: 'Zones'
  config.batch_actions = false
  permit_params :name

  actions :all, :except => [:destroy]

  index :download_links => false do
    selectable_column
    id_column
    column :name
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs "Zones" do
      f.input :name
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
    end
  end
end
