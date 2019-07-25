class AddColumnsToDoctor < ActiveRecord::Migration
  def change
    add_column :doctors, :gmc_cert_exp, :date
    add_column :doctors, :dbs_cert_exp, :date
    add_column :doctors, :mdu_mps_cert_exp, :date
    add_column :doctors, :last_appraisal_summary_exp, :date
    add_column :doctors, :reference_gp_exp, :date
    add_column :doctors, :hepatitis_b_status_exp, :date
    add_column :doctors, :child_protection_cert_exp, :date
    add_column :doctors, :adult_safeguarding_cert_exp, :date
  end
end
