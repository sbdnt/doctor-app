class AddIndexFromAppointmentToLocation < ActiveRecord::Migration
  def change
    add_reference :appointments, :location, index: true
  end
end
