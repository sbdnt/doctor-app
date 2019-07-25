ActiveAdmin.register PriceList do
  menu priority: 4, parent: 'Prices & Fee'
  config.batch_actions = false
  permit_params :name, :description, :price, :is_published

  actions :all, :except => [:new, :destroy]

  index :download_links => false do
    selectable_column
    id_column
    column :name do |item|
      item.price_type == 'bank_fee' ? link_to(item.name, admin_bank_holidays_path) : item.name
    end
    column :description
    column :price do |item|
      item.price.present? ? number_to_currency(item.price.to_f, precision: 2, unit: "£", separator: ".", delimiter: ",") : nil
    end
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs "PriceLists" do
      f.input :description
      if f.object.price_type != 'price_desc' && f.object.price_type != 'extra' && f.object.price_type != 'drug_delivery'
        f.input :price
      end
      if f.object.price_type == 'price_desc'
        f.input :is_published
      end
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :description
      row :price do |item|
        item.price.present? ? number_to_currency(item.price.to_f, precision: 2, unit: "£", separator: ".", delimiter: ",") : nil
      end
    end
  end
end
