ActiveAdmin.register GpdqSetting do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  
  permit_params :value, :time_unit
  config.batch_actions = false
  filter :name
  
  action_item 'Back to List', only: [:show, :edit, :new] do
    link_to 'Back to List', admin_gpdq_settings_path
  end

  index do
  	id_column
  	column :name
  	column :value
    column :time_unit
    column :created_at
    column :updated_at
    actions
    
  end

  form do |f|
    f.inputs "Settings" do
      f.input :name, input_html: {disabled: true} 
      f.input :value
      f.input :time_unit, collection: GpdqSetting.time_units.collect{|k, v| [k.titleize, k]}, :include_blank => true, input_html: {class: "time-unit-select2"}, as: :select
    end
    f.actions
  end

end
