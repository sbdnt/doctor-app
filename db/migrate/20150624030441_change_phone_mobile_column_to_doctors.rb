class ChangePhoneMobileColumnToDoctors < ActiveRecord::Migration
  def change
    rename_column :doctors, :phone_mobile, :phone_number
  end
end
