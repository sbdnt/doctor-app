class AddCompanyToDoctorAgency < ActiveRecord::Migration
  def change
  	add_column :agencies, :company_name, :string
  	add_column :doctors, :company_name, :string
  end
end
