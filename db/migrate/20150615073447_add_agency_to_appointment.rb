class AddAgencyToAppointment < ActiveRecord::Migration
  def change
    add_reference :appointments, :agency, index: true, foreign_key: true
  end
end
