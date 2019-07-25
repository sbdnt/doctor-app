class CreateGpdqEmails < ActiveRecord::Migration
  def change
    create_table :gpdq_emails do |t|
      t.string :department
      t.string :email
      t.boolean :is_published, default: false

      t.timestamps null: false
    end
  end
end
