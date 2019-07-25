class AddFieldToApplySchedule < ActiveRecord::Migration
  def change
  	add_column :apply_schedules, :week_day, :integer
  	add_column :apply_schedules, :is_apply_week, :boolean, default: false
  end
end
