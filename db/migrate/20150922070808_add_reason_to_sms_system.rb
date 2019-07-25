class AddReasonToSmsSystem < ActiveRecord::Migration
  def change
    add_column :sms_systems, :reason, :string
  end
end
