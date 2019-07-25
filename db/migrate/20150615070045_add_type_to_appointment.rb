class AddTypeToAppointment < ActiveRecord::Migration
  def change
    add_column :appointments, :apm_type, :integer, default: 0
  end
end
