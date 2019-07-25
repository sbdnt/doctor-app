class RemoveReferenceFromAppointmentFeeToPriceItem < ActiveRecord::Migration
  def change
    remove_column :appointment_fees, :price_item_id
  end
end
