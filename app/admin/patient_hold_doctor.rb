ActiveAdmin.register PatientHoldDoctor do
  menu priority: 1, parent: 'Patients'
  config.batch_actions = false

  actions :all, :except => [:new, :edit, :destroy]

  index :download_links => false do
    selectable_column
    id_column
    column 'Patient', :patientable
    column :patientable_type
    column :doctor_id do |p|
      p.doctor.try(:name)
    end
    column :hold_at
    column :release_at
    actions
  end
end
