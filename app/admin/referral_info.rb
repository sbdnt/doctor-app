ActiveAdmin.register ReferralInfo do

  menu parent: 'Vouchers'
  config.batch_actions = false

  actions :all, except: [:new, :edit, :destroy]

  index do
    selectable_column
    id_column
    column :referral_id
    column :referred_user_id
    column :refer_amount
    column :was_bonused
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :referral_id
      row :referred_user_id
      row :refer_amount
      row :was_bonused
    end
  end

end
