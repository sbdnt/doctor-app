class RemveCanceledByFromAppointment < ActiveRecord::Migration
  def change
  	remove_column :appointments, :canceled_by
  end
end
