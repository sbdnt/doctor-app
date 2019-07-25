class AddFieldToAgencyPeriod < ActiveRecord::Migration
  def change
    add_column :agency_periods, :is_apply_default_to_custom, :boolean
  end
end
