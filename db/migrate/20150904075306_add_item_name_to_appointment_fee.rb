class AddItemNameToAppointmentFee < ActiveRecord::Migration
  def change
    add_column :appointment_fees, :item_name, :string
  end
end
