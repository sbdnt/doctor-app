class AddAllowDoctorViewToPriceCategory < ActiveRecord::Migration
  def change
    add_column :price_categories, :allow_doctor_view, :boolean, default: true
  end
end
