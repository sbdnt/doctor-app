class DeviseCreateDoctors < ActiveRecord::Migration
  def change
    create_table(:doctors) do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :name
      t.string :phone_mobile
      t.string :phone_landline
      t.string :avatar
      t.string :gmc_cert
      t.string :dbs_cert
      t.string :mdu_mps_cert
      t.string :passport
      t.string :default_start_location
      t.string :last_appraisal_summary
      t.string :reference_gp
      t.string :hepatitis_b_status
      t.string :child_protection_cert
      t.string :adult_safeguarding_cert
      t.integer :status, default: 0
      t.integer :agency_id
      t.string :zones_covered
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

    add_index :doctors, :email,                unique: true
    add_index :doctors, :reset_password_token, unique: true
    # add_index :doctors, :confirmation_token,   unique: true
    # add_index :doctors, :unlock_token,         unique: true
  end
end
