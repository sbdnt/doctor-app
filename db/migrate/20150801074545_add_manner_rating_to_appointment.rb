class AddMannerRatingToAppointment < ActiveRecord::Migration
  def change
  	add_column :appointments, :rating_manner, :integer, default: 0
  end
end
