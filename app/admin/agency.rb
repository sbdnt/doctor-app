# ActiveAdmin.register Agency, namespace: :agency do
ActiveAdmin.register Agency do
  #permit_params :email, :password, :password_confirmation
  menu priority: 2
  config.batch_actions = false
  index :download_links => false do
    selectable_column
    # id_column
    column :name
    column :email
    column :phone_number
    column :address
    column :status
    column :reason
    column :answer_about_us
    column :created_at
    column :updated_at
    actions
  end
  filter :name
  filter :email
  filter :phone_number
  filter :address

  show do
    attributes_table do
      row :name
      row :email
      row :first_name
      row :last_name
      row :gender
      row :role
      row :address
      row :company_name
      row :phone_number
      row :account_number
      row :bank_name
      row :branch_address
      row :sort_code
      row :status
      row :reasonro
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "Admin Details" do
      f.input :name
      f.input :email
      if f.object.new_record?
        f.input :password
        f.input :password_confirmation
      end

      f.input :first_name
      f.input :last_name
      f.input :gender, as: :hidden, collection: Agency.genders.keys
      f.input :role, as: :select, collection: [Agency.roles.keys.last], include_blank: false
      f.input :address
      f.input :company_name
      f.input :phone_number
      f.input :account_number
      f.input :bank_name
      f.input :branch_address
      f.input :sort_code
      f.input :status, as: :radio, :label => "Status", :collection => Agency.modify_status.keys.to_a
      f.input :reason, as: :text
    end
    f.actions
  end

  controller do
    def scoped_collection
      super.where("role IS NULL or role IN (?)", [2,3])
    end
    def update
      update! do |format|
        format.html { redirect_to admin_agencies_path } if resource.valid?
      end
    end
    def create
      create! do |format|
        format.html { redirect_to admin_agencies_path } if resource.valid?
      end
    end
    def permitted_params
      if params[:action].to_s == "new" || params[:action].to_s == "create"
        params.permit agency: [:name, :email, :address, :company_name, :phone_number, :status, :account_number, :bank_name, :branch_address, :sort_code, :password, :password_confirmation, :first_name, :last_name, :gender, :role]
      else
        params.permit agency: [:name, :email, :address, :company_name, :phone_number, :status, :reason, :account_number, :bank_name, :branch_address, :sort_code, :first_name, :last_name, :gender, :role]
      end
    end
  end

end
