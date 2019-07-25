class CreateSmsSystems < ActiveRecord::Migration
  def change
    create_table :sms_systems do |t|
      t.references :doctor
      t.references :patient
      t.string :to
      t.string :originator
      t.text :message
      t.timestamps null: false
    end
  end
end
