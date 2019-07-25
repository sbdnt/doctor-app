class AddAnswerAboutUsToAgencies < ActiveRecord::Migration
  def change
    add_column :agencies, :answer_about_us, :string
  end
end
