ActiveAdmin.register Category do
  menu priority: 6, label: "Medical directory"
  config.batch_actions = false
  permit_params :title, :kind, elements_attributes: [:id, :name, :phone, :address, :open_at, :close_at, :_destroy, working_days_attributes: [:id, :week_day, :open_at, :close_at, :_destroy]]
  index :download_links => false do
    selectable_column
    # id_column
    column :title
    column "Type", :kind
    column "Number of Element", :element_count
    column :created_at
    column :updated_at
    actions
  end
  filter :title
  filter :kind, label: "Type"

  show do
    attributes_table do
      row :title
      row :kind, label: "Type"
      render :partial => "active_admin/categories/show_elements", locals: {category: category}
    end
  end

  form do |f|
    f.inputs "Admin Details" do
      f.input :title
      if f.object.new_record?
        f.input :kind, as: :select, :label => "Type", :collection => Category.kind.keys.to_a, prompt: "Select Type"
      else
        f.input :kind, as: :select, :label => "Type", :collection => Category.kind.keys.to_a, prompt: "Select Type", :input_html => { :disabled => true } 
      end
      f.has_many :elements, allow_destroy: true do |e|
        e.input :name
        e.input :phone
        e.input :address
        if f.object.kind == Element::INFORMATION
          e.has_many :working_days, allow_destroy: true do |wd|
            days = []
            Date::DAYNAMES.each_with_index { |x, i| days << [x, i] }
            wd.input :week_day, as: :select, label: "Day", :collection => days, include_blank: false
            wd.input :open_at, as: :time_picker
            wd.input :close_at, as: :time_picker
          end
        end
      end unless f.object.new_record?
    end 
    f.actions
  end

  controller do
    # def update
    #   update! do |format|
    #     format.html { redirect_to admin_agencies_path } if resource.valid?
    #   end
    # end
    # def create
    #   create! do |format|
    #     format.html { redirect_to admin_agencies_path } if resource.valid?
    #   end
    # end
  end


end
