class Api::V1::Docs::VouchersDoc < ActionController::Base
  def self.validate
    <<-EOS
      Updated: Tan - update voucher flow    
      GET http://gpdq.co.uk/api/v1/vouchers/:voucher_code/validate
        PARAMS {"auth_token": "wMEvSvS9zBa6-Ii6RWHpqg"}
        ===> There are 4 cases:
        - Unauthorized - 401:
          {
            "message": "Unauthorized"
          }

        - Success:
          {
            {
              "success": true,
              "message": "This voucher can be used"
            }
            status: 200
          }
        - Fail:
          {
            {
              "success": false,
              "message": "This voucher code already used!"
            }
            status: 200
          }
        - Fail:
          {
            {
              "success": false,
              "message": "This voucher code not found!"
            }
            status: 200
          }
    EOS
  end
end