class ChangeTypeDateOfCredits < ActiveRecord::Migration
  def up
    change_column(:credits, :expired_date, :datetime)
    change_column(:credits, :used_at, :datetime)
  end

  def down
    change_column(:credits, :expired_date, :date)
    change_column(:credits, :used_at, :date)    
  end
end
