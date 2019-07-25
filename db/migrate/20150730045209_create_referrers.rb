class CreateReferrers < ActiveRecord::Migration
  def change
    create_table :referrers do |t|
      t.string :name
      t.string :email
      t.references :patient
      t.boolean :is_notified, default: false

      t.timestamps null: false
    end
  end
end
