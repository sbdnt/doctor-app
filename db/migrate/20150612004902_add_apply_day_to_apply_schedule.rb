class AddApplyDayToApplySchedule < ActiveRecord::Migration
  def change
    add_column :apply_schedules, :is_apply_day, :boolean
  end
end
