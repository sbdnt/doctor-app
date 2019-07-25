ActiveAdmin.register Voucher do
  # menu parent: 'Vouchers'
  # menu priority: 10
  menu false
# # See permitted parameters documentation:
# # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#   permit_params :voucher_code, :amount, :appointment_id, :is_used

#   collection_action :generate_code, method: :get do
#     # Random, unguessable number as a base20 string
#     #  .reverse ensures we don't use first character (which may not take all values)
#     raw_string = SecureRandom.random_number( 2**80 ).to_s( 20 ).reverse
#     # e.g. "3ecg4f2f3d2ei0236gi"


#     # Convert Ruby base 20 to better characters for user experience
#     long_code = raw_string.tr( '0123456789abcdefghij', '234679QWERTYUPADFGHX' )
#     # e.g. "6AUF7D4D6P4AH246QFH"


#     # Format the code for printing
#     short_code = long_code[0..3] + '-' + long_code[4..7] + '-' + long_code[8..11]
#     # e.g. "6AUF-7D4D-6P4A"
#     render json: short_code
#   end

#   form :partial => "active_admin/vouchers/form"

end
