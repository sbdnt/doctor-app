class AddColumnsDeviceToDoctor < ActiveRecord::Migration
  def change
    add_column :doctors, :device_token, :text
    add_column :doctors, :platform, :string
  end
end
