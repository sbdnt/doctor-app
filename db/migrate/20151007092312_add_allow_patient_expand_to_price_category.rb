class AddAllowPatientExpandToPriceCategory < ActiveRecord::Migration
  def change
    add_column :price_categories, :allow_patient_expand, :boolean, default: false
  end
end
