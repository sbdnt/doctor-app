class AddStatusToSmsSystem < ActiveRecord::Migration
  def change
    add_column :sms_systems, :status, :integer
  end
end
