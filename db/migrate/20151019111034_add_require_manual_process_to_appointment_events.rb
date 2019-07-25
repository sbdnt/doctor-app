class AddRequireManualProcessToAppointmentEvents < ActiveRecord::Migration
  def change
    add_column :appointment_events, :require_manual_process, :boolean, default: false
  end
end
