ActiveAdmin.register ReferralCode do
  menu label: 'Referral Code', parent: 'Vouchers'
  config.batch_actions = false

  actions :all, except: [:new, :edit, :destroy]

  index do
    selectable_column
    id_column
    column :voucher_code
    column :description
    column :amount
    column :patient
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :voucher_code
      row :description
      row :amount
      row :patient
    end
  end

  # form do |f|
  #   f.inputs "Referral Code" do
  #     f.input :voucher_code
  #     f.input :description, :input_html => { :rows => 2 }
  #     f.input :is_percentage, as: :radio, collection: [["Percentage", true], ["GBP", false]], label: false
  #     f.input :amount
  #     f.input :started_date, :as => :string, :input_html => {:class => "hasDatetimePicker", :readonly => true}
  #     f.input :ended_date, :as => :string, :input_html => {:class => "hasDatetimePicker", :readonly => true}
  #   end
  #   f.actions
  # end

end
