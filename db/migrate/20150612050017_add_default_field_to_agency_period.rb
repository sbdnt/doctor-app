class AddDefaultFieldToAgencyPeriod < ActiveRecord::Migration
  def change
    add_column :agency_periods, :is_default_week, :boolean
  end
end
