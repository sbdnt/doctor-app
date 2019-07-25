class CreateAgencyPeriods < ActiveRecord::Migration
  def change
    create_table :agency_periods do |t|
      t.references :agency, index: true, foreign_key: true
      t.datetime :start_at
      t.datetime :end_at
      t.integer :default_common_status
      t.integer :default_specific_status
      t.integer :custom_status
      t.string :changed_by
      t.references :period, index: true, foreign_key: true
      t.references :doctor, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
