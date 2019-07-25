class RenameTableNotificationMachine < ActiveRecord::Migration
  def change
    rename_table :notification_machines, :push_machines
  end
end
