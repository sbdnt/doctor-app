class DropTableReferrals < ActiveRecord::Migration
  def up
    drop_table :referrals
  end

  def down
    create_table :referrals
  end
end
