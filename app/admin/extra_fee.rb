ActiveAdmin.register ExtraFee do
  menu priority: 5, parent: 'Prices & Fee'
  config.batch_actions = false
  permit_params :name, :price

  actions :all, :except => [:new, :destroy]

  index :download_links => false do
    selectable_column
    id_column
    column :name do |item|
      item.extra_type == 'bank_fee' ? link_to(item.name, admin_bank_holidays_path) : item.name
    end
    column :price do |item|
      item.price.present? ? number_to_currency(item.price.to_f, precision: 2, unit: "£", separator: ".", delimiter: ",") : nil
    end
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs "Extra Fees" do
      f.input :price
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :price do |item|
        item.price.present? ? number_to_currency(item.price.to_f, precision: 2, unit: "£", separator: ".", delimiter: ",") : nil
      end
    end
  end
end
