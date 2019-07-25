ActiveAdmin.register SubZone do
  menu priority: 1, parent: 'Zones'
  config.batch_actions = false
  permit_params :name, :zone_id

  actions :all, :except => [:destroy]

  index :download_links => false do
    selectable_column
    id_column
    column :zone_id do |sub|
      link_to sub.zone.try(:name), admin_zone_path(sub.zone)
    end
    column :name
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
      row :zone
      row :name
    end
  end
end
