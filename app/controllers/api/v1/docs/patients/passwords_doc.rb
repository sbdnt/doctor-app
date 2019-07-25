class Api::V1::Docs::Patients::PasswordsDoc <  ActionController::Base
  def_param_group :forgot_params do
    param :email, String, desc: "Patient's Email", :required => true
  end

  def_param_group :new_password do
    param :auth_token, String, desc: "Authentication token", required: true
    param :current_password, String, desc: "Patient's current password", :required => true
    param :new_password, String, desc: "Patient's new password", :required => true
  end

  def self.forgot_desc
    <<-EOS
    PUT 'http://gpdq.co.uk/api/v1/patients/passwords/forgot
      PARAMS {"email" => "test@gmail.com"}
      ===> There are 3 cases:

      - Status 200 in case reset password successfully:
      {
        "success": true
      }

      - Status 422 in case email not found:
      {
        "errors": "Email doesn't exist",
        "success": false
      }

      - Status 422 in case errors:
      {
        "success": false
        "errors": "Error message"
      }
    EOS
  end

  def self.new_password
    <<-EOS
    Updated: Thanh
    PUT 'http://gpdq.co.uk/api/v1/patients/passwords/new_password
      PARAMS {"auth_token" => "abcd", "current_password" => "12345678", "new_password" => "1234qwer"}
      ===> There are 5 cases:

      - Status 200 in case change password successfully:
      {
        "success": true
      }

      - Status 400 in case new password wrong format:
      {
        "errors": "Password is too short (minimum is 8 characters)",
        "success": false
      }

      - Status 422 in case patient's current password is wrong:
      {
        "errors": "Current password is wrong",
        "success": false
      }

      - Status 401 in case unauthorized:
      {
        "message": "Unauthorized"
      }

      -Status 422 in case missing parameters:
      {
        "message": "Missing parameters",
        "errors": "current_password can't be blank"
      }
    EOS
  end

end