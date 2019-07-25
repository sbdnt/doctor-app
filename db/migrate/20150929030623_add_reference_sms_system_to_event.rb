class AddReferenceSmsSystemToEvent < ActiveRecord::Migration
  def change
    add_reference :sms_systems, :event, index: true
  end
end
