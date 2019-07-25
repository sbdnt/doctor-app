class AddVoucherIdToAppointment < ActiveRecord::Migration
  def change
    add_reference :appointments, :voucher, index: true
  end
end
