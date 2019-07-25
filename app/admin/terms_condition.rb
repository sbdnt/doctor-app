ActiveAdmin.register TermsCondition do
  menu priority: 2, parent: 'T&C and Help'
  config.batch_actions = false

  actions :all, :except => [:new, :destroy]
  permit_params :content

  index :download_links => false do
    selectable_column
    id_column
    column :content do |terms_condition|
      raw(truncate(terms_condition.content, omision: "...", length: 100))
    end
    column :created_at
    column :updated_at
    actions
  end
  form do |f|
    f.inputs "TermsConditions" do
      f.input :content, :input_html => { :class => "tinymce txt_area", :rows => 40, :cols => 120 }
    end
    f.actions
  end

  show do
    attributes_table do
      row :content do |terms_condition|
        raw terms_condition.content
      end
    end
  end


end
