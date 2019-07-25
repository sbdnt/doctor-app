class AddAnswerAboutUsToDoctors < ActiveRecord::Migration
  def change
    add_column :doctors, :answer_about_us, :string
  end
end
