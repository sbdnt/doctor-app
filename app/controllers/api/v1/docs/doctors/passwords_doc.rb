class Api::V1::Docs::Doctors::PasswordsDoc < ActionController::Base

  def self.forgot
    <<-EOS
    Author: Thanh
    PUT http://gpdq.co.uk/api/v1/doctors/passwords/forgot
      PARAMS {"email" => "test@gmail.com"}
      ===> There are 4 cases:

      - Success - Status 200:
      {
        "success": true
      }

      - Faile - Status 422:
      {
        "success": false,
        "errors": "Missing email"
      }

      - Fail - Status 422:
      {
        "success": false,
        "errors": "Email doesn't exist"
      }

      - Fail - Status 422:
      {
        "success": false,
        "errors": "Error message"
      }
      
    EOS
  end
end