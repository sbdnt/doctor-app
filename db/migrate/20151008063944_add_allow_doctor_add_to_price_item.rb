class AddAllowDoctorAddToPriceItem < ActiveRecord::Migration
  def change
    add_column :price_items, :allow_doctor_add , :boolean, default: true
  end
end
