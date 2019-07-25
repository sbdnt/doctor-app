class AddIsCurrentBillingToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :is_current_billing, :boolean, default: false
  end
end
