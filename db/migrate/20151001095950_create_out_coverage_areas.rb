class CreateOutCoverageAreas < ActiveRecord::Migration
  def change
    create_table :out_coverage_areas do |t|
      t.string :patient_name
      t.string :patient_email
      t.string :post_code
      t.timestamps null: false
    end
  end
end
