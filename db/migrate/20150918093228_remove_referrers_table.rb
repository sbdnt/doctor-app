class RemoveReferrersTable < ActiveRecord::Migration
  def up
    drop_table :referrers
  end

  def down
    create_table :referrers
  end
end
