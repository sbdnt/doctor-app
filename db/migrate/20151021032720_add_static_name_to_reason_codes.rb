class AddStaticNameToReasonCodes < ActiveRecord::Migration
  def change
    add_column :reason_codes, :static_name, :string
    add_index :reason_codes, :static_name
  end
end
