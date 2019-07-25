class RenamePriceToPricePerUnitOnAppointmentFee < ActiveRecord::Migration
  def change
    rename_column :appointment_fees, :price, :price_per_unit
  end
end
