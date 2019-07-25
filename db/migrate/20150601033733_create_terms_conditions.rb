class CreateTermsConditions < ActiveRecord::Migration
  def change
    create_table :terms_conditions do |t|
      t.text :content

      t.timestamps null: false
    end
  end
end
