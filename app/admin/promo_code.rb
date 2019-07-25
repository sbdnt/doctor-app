ActiveAdmin.register PromoCode do
  menu label: 'Promotional Code', parent: 'Vouchers'
  config.batch_actions = false
  permit_params :voucher_code, :amount, :is_used, :description, :is_percentage, :started_date, :ended_date

  index do
    # id_column
    column :id
    column "Reference", :voucher_code
    column :description
    column :percentage do |voucher_code|
      if voucher_code.is_percentage
        voucher_code.amount
      else
        nil
      end
    end
    

    column "GBP amount", :amount do |voucher_code|
      if voucher_code.is_percentage
        nil
      else
        voucher_code.amount
      end
    end
    column :started_date
    column :ended_date
    column :is_used
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs "Promotional Code" do
      f.input :voucher_code
      f.input :description, :input_html => { :rows => 2 }
      f.input :is_percentage, as: :radio, collection: [["Percentage", true], ["GBP", false]], label: false
      f.input :amount
      f.input :started_date, :as => :string, :input_html => {:class => "hasDatetimePicker", :readonly => true}
      f.input :ended_date, :as => :string, :input_html => {:class => "hasDatetimePicker", :readonly => true}
    end
    f.actions
  end

end

