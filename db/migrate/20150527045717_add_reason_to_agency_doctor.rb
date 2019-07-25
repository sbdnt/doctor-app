class AddReasonToAgencyDoctor < ActiveRecord::Migration
  def change
    add_column :doctors, :reason, :text
    add_column :agencies, :reason, :text
  end
end
