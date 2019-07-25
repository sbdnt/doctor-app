class AddDeviseToPatients < ActiveRecord::Migration
  def self.up 
    change_table(:patients) do |t|
      ## contact and payment info
      t.string  :phone_number
      t.string  :account_number
      t.string  :bank_name
      t.string  :branch_address
      t.string  :sort_code
      t.integer :status, default: 0

      ## for FB login
      t.string  :provider
      t.string  :uid

      ## Database authenticatable
      t.change :email, :string, null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

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

      # Uncomment below if timestamps were not included in your original model.
      # t.timestamps
    end

    #add_index :patients, :email,                unique: true
    add_index :patients, :reset_password_token, unique: true
    # add_index :patients, :confirmation_token,   unique: true
    # add_index :patients, :unlock_token,         unique: true
  end

  def self.down
    change_table(:patients) do |t|
      t.remove :phone_number
      t.remove :account_number
      t.remove :bank_name
      t.remove :branch_address
      t.remove :sort_code
      t.remove :status
      t.remove :provider
      t.remove :uid
      t.change :email, :string
      t.remove :encrypted_password
      t.remove :reset_password_token
      t.remove :reset_password_sent_at
      t.remove :remember_created_at
      t.remove :sign_in_count
      t.remove :current_sign_in_at
      t.remove :last_sign_in_at
      t.remove :current_sign_in_ip
      t.remove :last_sign_in_ip
    end

    remove_index :patients, :email
  end

end