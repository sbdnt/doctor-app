ActiveAdmin.register Help do
  menu priority: 0, parent: 'T&C and Help', label: "FAQ Patients"
  config.batch_actions = false

  permit_params :title, :content, :is_published
  index :download_links => false, :title => "FAQ Patients" do
    selectable_column
    id_column
    column :title do |help|
      truncate(help.title, omision: "...", length: 100)
    end
    column :content do |help|
      truncate(help.content, omision: "...", length: 100)
    end
    column :is_published
    column :created_at
    column :updated_at
    actions
  end
  form do |f|
    f.inputs "FAQ Patients" do
      f.input :title
      f.input :content, :input_html => { :class => "tinymce txt_area", :rows => 40, :cols => 120 }
      f.input :is_published, as: :radio
    end
    f.actions
  end

  show do
    attributes_table do
      row :title
      row :content do |help|
        raw help.content
      end
      row :is_published
    end
  end
end
