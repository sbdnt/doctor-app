class PaypalPaymentsController < ApplicationController
  def create

	  @payment = PayPal::SDK::REST::Payment.new({
		  :intent => "sale",
		  :payer => {
		    :payment_method => "paypal" },
		  :redirect_urls => {
		    :return_url => "https://devtools-paypal.com/guide/pay_paypal/ruby?success=true",
		    :cancel_url => "https://devtools-paypal.com/guide/pay_paypal/ruby?cancel=true" },
		  :transactions => [ {
		    :amount => {
		      :total => "12",
		      :currency => "USD" },
		    :description => "creating a payment" } ] } )

    @payment.create

  end

  def get_access_token
  	puts "get_access_token!!!!!!!!!!!!!!!!!!"
  	puts params.inspect

  	render :text=>'ok'
  end


end
