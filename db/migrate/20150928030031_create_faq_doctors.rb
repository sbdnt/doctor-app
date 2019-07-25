class CreateFaqDoctors < ActiveRecord::Migration
  def change
    create_table :faq_doctors do |t|
      t.string :title
      t.text :content
      t.boolean :is_published, default: false
      t.timestamps null: false
    end
  end
end
