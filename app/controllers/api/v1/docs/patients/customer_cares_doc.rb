class Api::V1::Docs::Patients::CustomerCaresDoc <  ActionController::Base
  def self.faq_list
    <<-EOS
      GET 'http://gpdq.co.uk/api/v1/patients/customer_cares/faq_list
      ===> There are 1 case:

      - Status 200 in case get FAQ list successfully:
      {
        "success": true,
        "faq_list": [
          {
            "uid": 2,
            "title": "How to doctor sign up?",
            "content": "<div class=\"content-container content-container--answer\" style=\"margin: 0px; padding: 0px; border: 0px; outline: 0px; font-size: 13px; font-family: Roboto, 'Helvetica Neue', Helvetica, sans-serif; vertical-align: baseline; word-wrap: break-word; color: #212121; line-height: 20px;\">\r\n<ol style=\"margin: 4px 0px 12px; padding: 0px; border: 0px; outline: 0px; font-weight: inherit; font-style: inherit; font-size: inherit; font-family: inherit; vertical-align: baseline;\">\r\n<li style=\"margin: 4px 0px 4px 20px; padding: 0px; border: 0px; outline: 0px; font-weight: inherit; font-style: inherit; font-size: inherit; font-family: inherit; vertical-align: baseline;\">Visit the&nbsp;<a style=\"margin: 0px; padding: 0px; border: 0px; outline: 0px; font-weight: inherit; font-style: inherit; font-size: inherit; font-family: inherit; vertical-align: baseline; color: #7759ae; text-decoration: none;\" href=\"https://www.google.com/accounts/ForgotPasswd\">password-assistance page</a>.</li>\r\n<li style=\"margin: 4px 0px 4px 20px; padding: 0px; border: 0px; outline: 0px; font-weight: inherit; font-style: inherit; font-size: inherit; font-family: inherit; vertical-align: baseline;\">Enter your username (your full email address).</li>\r\n<li style=\"margin: 4px 0px 4px 20px; padding: 0px; border: 0px; outline: 0px; font-weight: inherit; font-style: inherit; font-size: inherit; font-family: inherit; vertical-align: baseline;\">Type the letters shown in the distorted picture into the appropriate field.</li>\r\n<li style=\"margin: 4px 0px 4px 20px; padding: 0px; border: 0px; outline: 0px; font-weight: inherit; font-style: inherit; font-size: inherit; font-family: inherit; vertical-align: baseline;\">Click&nbsp;<span style=\"margin: 0px; padding: 0px; border: 0px; outline: 0px; font-weight: bold; font-style: inherit; font-size: inherit; font-family: inherit; vertical-align: baseline;\">Submit</span>. You'll receive a message at the address registered as your Google Account username. Follow the instructions in this message to reset your password.</li>\r\n</ol>\r\n</div>"
          }
        ]
      }
    EOS
  end

  def self.gpdq_email
    <<-EOS
      GET 'http://gpdq.co.uk/api/v1/patients/customer_cares/gpdq_email
      ===> There are 1 case:

      - Status 200 in case get GPDQ Email list successfully:
      {
        "success": true,
        "email_list": [
          {
            "uid": 1,
            "department": "Administration",
            "email": "administration@gpdq.co.uk"
          },
          {
            "uid": 2,
            "department": "Customer Service",
            "email": "customer_service@gpdq.co.uk"
          }
        ]
      }
    EOS
  end

  def self.gpdq_phone
    <<-EOS
      GET 'http://gpdq.co.uk/api/v1/patients/customer_cares/gpdq_phone
      ===> There are 1 case:

      - Status 200 in case get GPDQ Phone list successfully:
      {
        "success": true,
        "phone_list": [
          {
            "uid": 1,
            "department": "Administration",
            "phone_number": "+456"
          },
          {
            "uid": 2,
            "department": "Customer Service",
            "phone_number": "+4123"
          }
        ]
      }
    EOS
  end
end