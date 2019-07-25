ActiveAdmin.register PriceItem do
  menu priority: 2, parent: 'Prices & Fee'

  permit_params :name, :description, :category_id, :price, :is_default, :price_per_unit, :quantity, :add_default, :allow_doctor_add, :price_type, :editable
  config.batch_actions = false
  filter :name
  filter :category_id

  action_item 'Back to List', only: [:show, :edit, :new] do
    link_to 'Back to List', admin_price_items_path
  end

  action_item 'Back to List', only: [:index] do
    link = link_to 'New Default Item', new_admin_price_item_path(add_default: true), class: "add-default-price-item"
  end

  index do
    selectable_column
    id_column
    column :name
    column :description
    column :category_id do |item|
      link_to item.price_category.name, admin_price_category_path(item.price_category.id)
    end
    column :price_per_unit
    column :quantity
    column :is_default
    column :allow_doctor_add
    column :editable
    column :created_at
    column :updated_at
    # actions
    column :actions do |resource|
      div(class: "table_actions") do
        links = link_to I18n.t('active_admin.view'), resource_path(resource)
        links += link_to "Edit", edit_resource_path(resource)
        # if resource.price_type != 'extension' && resource.price_type != 'appointment_fee'
        if resource.price_type.blank?
          links += link_to "Delete", resource_path(resource), method: :delete, data: { confirm: "Are you sure you want to delete this?" }
        else
          links += ''
        end
      end
    end
  end

  form do |f|
    f.inputs "Price Items" do
      if f.object.new_record?
        f.input :category_id, :collection => PriceCategory.order('name'), :label_method => :name, :value_method => :id, :include_blank => false, as: :select
      end
      f.input :name
      f.input :description
      f.input :price_per_unit
      f.input :is_default, as: :hidden, input_html: {:checked => "checked", value: 1} if params[:add_default] == 'true'
      f.input :allow_doctor_add
      f.input :editable
      f.input :quantity
      if f.object.new_record?
        f.input :price_type
      end
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :description
      row :category_id do |item|
        link_to item.price_category.name, admin_price_category_path(item.price_category.id)
      end
      row :price_per_unit
      row :is_default
      row :allow_doctor_add
      row :editable
      row :quantity
    end
  end

  controller do
    def create
      @price_item = PriceItem.new(permitted_params[:price_item])
      if @price_item.save
        redirect_to admin_price_items_path
      else
        render :new, add_default: "true"
      end
    end
  end

end
