class CreateAboutUsQuestions < ActiveRecord::Migration
  def change
    create_table :about_us_questions do |t|
      t.string :content, null: false

      t.timestamps null: false
    end
  end
end
