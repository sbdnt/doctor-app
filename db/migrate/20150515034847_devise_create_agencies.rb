class DeviseCreateAgencies < ActiveRecord::Migration
  # def migrate(direction)
  #   super
  #   # Create a default user
  #   Agency.create!(email: 'agency@doctorapp.com', password: '1234qwer', password_confirmation: '1234qwer') if direction == :up
  # end

  def change
    create_table(:agencies) do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :name
      t.string :address
      t.string :phone_number
      t.string :account_number
      t.string :bank_name
      t.string :branch_address

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet     :current_sign_in_ip
      t.inet     :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at


      t.timestamps
    end

    add_index :agencies, :email,                unique: true
    add_index :agencies, :reset_password_token, unique: true
    # add_index :agencies, :confirmation_token,   unique: true
    # add_index :agencies, :unlock_token,         unique: true
  end
end
