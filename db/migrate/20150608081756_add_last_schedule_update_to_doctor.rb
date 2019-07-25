class AddLastScheduleUpdateToDoctor < ActiveRecord::Migration
  def change
    add_column :doctors, :last_schedule_update, :datetime
  end
end
