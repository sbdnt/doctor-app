class RemoveMessageFromAppointmentEvents < ActiveRecord::Migration
  def change
    remove_column :appointment_events, :message, :string
  end
end
