class AddAboutToDoctors < ActiveRecord::Migration
  def change
    add_column :doctors, :description, :text
  end
end
