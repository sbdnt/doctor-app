ActiveAdmin.register Invoice do
  menu priority: 0, parent: 'Prices & Fee'
  permit_params :total_prices, :appointment_id, :total_extra, price_items_attributes: [:id, :_destroy, :category_id]
  config.batch_actions = false

  filter :total_prices
  filter :appointment_id

  action_item 'Back to List', only: [:show, :edit, :new] do
    link_to 'Back to List', admin_invoices_path
  end

  index do
    selectable_column
    id_column
    column :appointment_id do |item|
      link_to item.appointment_id, admin_appointment_path(item.appointment_id)
    end
    column :status
    column "Price Items", :price_item_ids do |item|
      item.price_items.map(&:name).join(', ')
    end
    column :total_extra do |item|
      number_to_currency(item.total_extra, precision: 2, unit: "£", separator: ".", delimiter: ",")
    end
    column :total_prices do |item|
      number_to_currency(item.total_prices, precision: 2, unit: "£", separator: ".", delimiter: ",")
    end
    column :created_at
    column :updated_at
    # actions
    column :actions do |resource|
      div(class: "table_actions") do
        links = link_to I18n.t('active_admin.view'), resource_path(resource)
        if resource.pending?
          links += link_to "Edit", edit_resource_path(resource)
        end
        links += link_to "Delete", resource_path(resource), method: :delete, data: { confirm: "Are you sure you want to delete this?" }
      end
    end
  end

  # form partial: 'active_admin/invoices/invoices_form'
  form do |f|
    f.inputs "", class: "invoice-form" do
      if f.object.new_record?
        f.input :appointment_id, :collection => Appointment.where(is_canceled: 0).order('end_at').map{|app| [app.id, app.id]}, :include_blank => false, input_html: {class: "zone-select2"}, as: :select
      else
        f.input :appointment_id, :collection => Appointment.order('end_at').map{|app| [app.id, app.id]}, :include_blank => false, input_html: {disabled: true, class: "zone-select2"}, as: :select
      end
      f.input :status, as: :radio, :label => "Status", :collection => Invoice.modify_status.keys.to_a
      f.inputs "", class: "invoice-has-many" do
        f.has_many :price_items, allow_destroy: true, :heading => false do |z|
          if z.object.try(:category_id).present?
            z.input :category_id, label: "Select Price Category", :collection => PriceCategory.order('name'), :label_method => :name, :value_method => :id, :include_blank => false, input_html: {disabled: true, class: "zone-select2 price-category"}, as: :select
            z.input :id, label: "Select Price Item", :collection => PriceItem.where(category_id: z.object.try(:category_id)).order('name'), :label_method => :name, :value_method => :id, :include_blank => false, input_html: {disabled: true, class: "zone-select2"}, as: :select
            z.input :price_per_unit, label: "Price", input_html: {disabled: true, class: "price-input"}
            z.input :quantity, label: "Quantity", input_html: {disabled: true, class: "quantity"}
          else
            z.input :category_id, label: "Select Price Category", :collection => PriceCategory.order('name'), :label_method => :name, :value_method => :id, :include_blank => false, input_html: {class: "zone-select2 price-category"}, as: :select
            z.input :id, label: "Select Price Item", :collection => PriceItem.where(category_id: PriceCategory.order('name').first.try(:id), is_default: false).order('name'), :label_method => :name, :value_method => :id, :include_blank => false, input_html: {class: "zone-select2 price_items"}, as: :select
            z.input :price_per_unit, label: "Price", input_html: {disabled: true, value: PriceItem.where(category_id: PriceCategory.order('name').first.try(:id), is_default: false).order('name').first.try(:price_per_unit).to_s, class: "price-input"}
            z.input :quantity, label: "Quantity", input_html: {class: "quantity"}
          end
        end
      end
    end
    f.actions
  end

  show do
    attributes_table do
      row :appointment_id do |item|
        link_to item.appointment_id, admin_appointment_path(item.appointment_id)
      end
      row :status
      # row :price_items do |item|
      #   item.price_items.map(&:name).join(', ')
      # end
      # row :total_prices
      render :partial => "active_admin/invoices/show_invoices", locals: {invoice: invoice}
    end
  end

  controller do
    def new
      super do |format|
        resource.appointment_id = params[:appointment_id] if params[:appointment_id].present?
        list_default = PriceItem.where(is_default: true)
        list_default = [PriceItem.new] if list_default.blank?
        resource.price_items = list_default
      end
    end

    def update
      update! do |format|
        if params[:invoice][:price_items_attributes].present?
          list_items = params[:invoice][:price_items_attributes].values
          list_items.each do |item|
            puts "item = #{item.inspect}"
            if item['id'].present?
              if item['_destroy'].present? && item['_destroy'] == '1'
                item_invoice = ItemsInvoice.find_by( invoice_id: resource.id, price_item_id: item['id'].to_i )
                item_invoice.destroy if item_invoice.present?
              else
                if item['category_id'].present?
                  item_invoice = ItemsInvoice.create( invoice_id: resource.id, price_item_id: item['id'].to_i )
                  item_invoice.update_item_price if resource.status != 'pending'
                end
              end
            end
          end
        end
        # Test update invoice price
        resource.update_total_price
        format.html { redirect_to admin_invoices_path } if resource.valid?
      end
    end

    def create
      @invoice = Invoice.new(permitted_params[:invoice])

      if @invoice.save
        list_items = params[:invoice][:price_items_attributes].values
        list_items.each do |item|
          if item['id'].present?
            if item['_destroy'].present? && item['_destroy'] == '1'
              item_invoice = ItemsInvoice.find_by( invoice_id: @invoice.id, price_item_id: item['id'].to_i )
              item_invoice.destroy if item_invoice.present?
            else
              item_invoice = ItemsInvoice.create( invoice_id: @invoice.id, price_item_id: item['id'].to_i )
              item_invoice.update_item_price
            end
          end
        end
        item_list = ItemsInvoice.where( invoice_id: @invoice.id )
        # if item_list.size > 0
        #   total_prices = item_list.map(&:item_price).map(&:to_i).reduce(:+)
        #   @invoice.update_attributes( total_prices: total_prices )
        # end
        @invoice.update_total_price
        redirect_to admin_invoices_path
      else
        list_item_ids = params[:invoice][:price_items_attributes].values.map{|i| i['id']}.uniq.compact
        list_items = PriceItem.where(id: list_item_ids)
        resource.price_items = list_items
        render :new
      end
    end

    def permitted_params
      # do not get permission for price_items_attributes
      params.permit invoice: [:appointment_id, :status], price_items_attributes: [:_destroy, :id, :category_id]
    end
  end
end
