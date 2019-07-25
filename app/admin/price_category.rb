ActiveAdmin.register PriceCategory do
  menu priority: 1, parent: 'Prices & Fee'

  permit_params :name, :allow_expand, :allow_edit_price, :allow_patient_expand, :category_order, :allow_doctor_view, :cat_type
  config.batch_actions = false
  filter :name

  actions :all, :except => [:destroy]
  action_item 'Back to List', only: [:show, :edit, :new] do
    link_to 'Back to List', admin_price_categories_path
  end

  index do
    selectable_column
    id_column
    column :name
    column "Allow Doctor Expand", :allow_expand
    column :allow_doctor_view
    column :allow_edit_price
    column :allow_patient_expand
    column :category_order
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs "Price Categories" do
      f.input :name
      f.input :allow_expand
      f.input :allow_edit_price
      f.input :allow_doctor_view
      f.input :allow_patient_expand
      f.input :category_order
      if f.object.new_record?
        f.input :cat_type
      end
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :allow_expand
      row :allow_doctor_view
      row :allow_edit_price
      row :allow_patient_expand
      row :category_order
    end
  end

end
