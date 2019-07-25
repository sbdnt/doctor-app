class AddDayAgencyPeriod < ActiveRecord::Migration
  def change
  	add_column :agency_periods, :week_day, :integer
  	add_column :agency_periods, :starttime_at, :string
  	add_column :agency_periods, :endtime_at, :string
  end
end
