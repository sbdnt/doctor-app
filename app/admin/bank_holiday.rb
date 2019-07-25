ActiveAdmin.register BankHoliday do
  menu priority: 6, parent: 'Prices & Fee'
  config.batch_actions = false
  permit_params :event_name, :event_date

  actions :all

  index :download_links => false do
    selectable_column
    id_column
    column :event_name
    column :event_date
    column "Day" do |bank|
      bank.event_date.strftime("%A")
    end
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs "Bank Holidays" do
      f.input :event_name, :input_html => {:maxlength => 255}
      f.input :event_date, :as => :string, :input_html => {:class => "hasDatetimePicker", :readonly => true}
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :event_name
      row :event_date
      row "day" do |bank|
        bank.event_date.strftime("%A")
      end
    end
  end
end
