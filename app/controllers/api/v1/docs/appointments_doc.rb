class Api::V1::Docs::AppointmentsDoc < ActionController::Base
  def self.fee
    <<-EOS
      GET 'http://gpdq.co.uk/api/v1/appointments/fee
      ===> There are 1 case:

      - Status 200 in case get appointment fee successfully:
      {
        "fee": 345
      }
    EOS
  end
end