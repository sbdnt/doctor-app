ActiveAdmin.register DoctorReturnAppointment do
  menu label: 'Doctor Return Lists', parent: 'Doctors'
  config.batch_actions = false

  actions :all, except: [:new, :edit, :destroy]
  
  index do
    selectable_column
    id_column
    column :doctor
    column :appointment_id
    column 'Patient', :patient_name
    column :created_at
    column :updated_at
    
    actions
  end

end
