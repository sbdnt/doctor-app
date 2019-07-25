ActiveAdmin.register PushMachine do

  # Permit params
  permit_params :appointment_id, :event_id, :receiver_id, :receiver_role, :message, :app_message

  # Custom Form
  form do |f|
    f.inputs do
      f.input :appointment, as: :select, collection: Appointment.order(id: :desc).pluck(:id)
      f.input :event
      f.input :receiver_id, label: "Receiver ID"
      f.input :receiver_role, as: :select, collection: [["Patient", "patient"], ["Doctor", "doctor"]], selected: 1, include_blank: false
      f.input :message
      f.input :app_message
    end
    f.actions do
      f.action :submit
      f.action :cancel
    end
  end
end