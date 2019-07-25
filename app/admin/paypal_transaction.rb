ActiveAdmin.register PaypalTransaction do
  menu priority: 7, parent: 'Prices & Fee'

  # permit_params :name, :description, :category_id, :price, :is_default, :price_per_unit, :quantity, :add_default
  config.batch_actions = false
  filter :appointment_id
  filter :status, as: :select, :collection =>  PaypalTransaction.statuses.map{|x| [x[0].to_s.upcase.gsub("_", " "), x[1]]}
  filter :amount
  filter :payment_type, as: :select, :collection =>  PaypalTransaction.payment_types.map{|x| [x[0].to_s.upcase.gsub("_", " "), x[1]]}

  action_item 'Back to List', only: [:show, :index] do
    link_to 'Back to List', admin_paypal_transactions_path
  end
  actions :all, :except => [:new, :edit, :destroy]

  index do
    selectable_column
    id_column
    column :appointment_id do |item|
      if item.appointment_id.present?
        link_to item.appointment_id, admin_appointment_path(item.appointment_id)
      else
        ""
      end
    end
    column :status
    column :amount do |tran|
      number_to_currency(tran.amount.to_f, precision: 2, unit: "£", separator: ".", delimiter: ",")
    end
    column :payment_type
    column :payment_id
    column :currency
    column :description
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :appointment_id do |item|
        if item.appointment_id.present?
          link_to item.appointment_id, admin_appointment_path(item.appointment_id)
        else
          ""
        end
      end
      row :status
      row :amount do |tran|
        number_to_currency(tran.amount.to_f, precision: 2, unit: "£", separator: ".", delimiter: ",")
      end
      row :payment_type
      row :payment_id
      row :currency
      row :description
      row :created_at
    end
  end
end
