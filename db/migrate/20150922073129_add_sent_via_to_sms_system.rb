class AddSentViaToSmsSystem < ActiveRecord::Migration
  def change
    add_column :sms_systems, :sent_via, :integer
  end
end
