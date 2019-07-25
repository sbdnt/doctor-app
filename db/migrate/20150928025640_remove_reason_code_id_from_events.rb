class RemoveReasonCodeIdFromEvents < ActiveRecord::Migration
  def change
    remove_column :events, :reason_code_id, :integer
  end
end
