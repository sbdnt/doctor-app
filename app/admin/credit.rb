ActiveAdmin.register Credit do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  
  permit_params :patient_id, :appointment_id, :patient_reference_id, :appointment_id, :patient_reference_id, :credit_number, :expired_date, :is_used, :credit_type, :used_at, :used_appointment_id

  index do
  	id_column
  	column :patient_id, 'Patent' do |item|
      item.patient.fullname
    end
    column :appointment_id
    column :patient_reference_id
    column :credit_number
    column :created_at
  	column :expired_date
    column :is_used
    column :credit_type
    column :used_at
    column :used_appointment_id
    
    actions

  end

  form do |f|
    f.inputs "Credit" do
      f.input :patient_id, as: :select, collection: Patient.order('fullname').map{|p| [p.fullname, p.id]}
      f.input :credit_number
      f.input :credit_type, as: :select, collection: Credit.credit_types.keys, include_blank: false
      f.input :expired_date, :as => :string, :input_html => {:class => "hasDatetimePicker", :readonly => true}
      # f.input :used_at, :as => :string, :input_html => {:class => "hasDatetimePicker", :readonly => true}
      f.input :is_used
    end 
    f.actions
  end
end
