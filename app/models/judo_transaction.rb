class JudoTransaction < ActiveRecord::Base
  enum payment_type: {"PreAuth" => 1, "Payment" => 2, "Collection" => 3}
  enum status: {"Success" => 1, "Failure" => 2, "Declined" => 3}
  # Define card type
  CARD_TYPES = {"0" => "UNKNOWN", "1" => "VISA", "2" => "MASTERCARD", "11" => "VISA DEBIT", "12" => "MASTERCARD DEBIT"}

  def self.get_and_create_transaction(consumer_reference, appoint_id)
    headers = {"API-Version" => 4.1, "Content-Type" => "application/json"}
    res = []
    results = RestClient.get("https://#{JUDOPAY[:token]}:#{JUDOPAY[:secret]}@#{JUDOPAY[:host]}/transactions", headers) {
      |rs, req, result| 
      res = Hash.from_xml(rs)["SearchResults"]["Results"]["Receipt"]
      res = res.select{|receipt| receipt["Consumer"]["YourConsumerReference"] == consumer_reference}
    }
    self.create_tran(res.first.symbolize_keys, appoint_id)
  end

  # def self.create_tran(obj, appoint_id)
  #   self.create(payment_type: obj[:Type], status: obj[:Result], amount: obj[:Amount], consumer_token: obj["ConsumerToken"],
  #               your_consumer_reference: obj[:Consumer]["YourConsumerReference"], currency: obj[:Currency],
  #               net_amount: obj[:NetAmount], receipt_id: obj[:ReceiptId], 
  #               your_payment_reference: obj[:YourPaymentReference], card_type: obj[:CardDetails]["CardType"], appointment_id: appoint_id)
  # end

  def self.create_tran(obj, appoint_id)
    puts "obj = #{obj}"
    if obj[:errorMessage].present?
      
    else
      self.create(payment_type: obj[:type], status: obj[:result], amount: obj[:amount], consumer_token: obj[:consumer]["consumerToken"],
                  your_consumer_reference: obj[:consumer]["yourConsumerReference"], currency: obj[:currency],
                  net_amount: obj[:netAmount], receipt_id: obj[:receiptId], 
                  your_payment_reference: obj[:yourPaymentReference], card_type: JudoTransaction::CARD_TYPES[obj[:cardDetails]["cardType"].to_s], appointment_id: appoint_id)
    end
  end

end
