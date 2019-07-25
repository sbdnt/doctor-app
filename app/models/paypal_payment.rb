class PaypalPayment
	def initialize(refresh_token, total=0)
		@refresh_token = refresh_token
		@total = total
	end

	def execute
  	ret = {}
		
		puts "total = #{@total}"
		access_token = PaypalPayment.get_access_token(@refresh_token)
		payment = PaypalPayment.create_payment(access_token, @total) 
 
		puts "execute_future!!!!!!!!!!!!!!!!!!!!!!!!!!"
		puts payment.inspect
		puts "========================================"

		if !payment.blank? && payment['payment_id']
		  ret = {success: true}.merge(payment).symbolize_keys
		else
		  ret = {success: false, errors: "Payment has error" }
		end
		ret
	end

	def capture_payment
  	ret = {}
		
		puts "total = #{@total}"
		# total = ActionController::Base.helpers.number_to_currency(total, unit: '')
		access_token = PaypalPayment.get_access_token(@refresh_token)
		payment = PaypalPayment.capture_payment(access_token, @total) 
 
		puts "capture_payment!!!!!!!!!!!!!!!!!!!!!!!!!!"
		puts payment.inspect
		puts "========================================="

		if !payment.blank? && payment['payment_id']
		  ret = {success: true}.merge(payment).symbolize_keys
		else
		  ret = {success: false, errors: "Payment has error" }
		end
		ret
	end

	def self.get_refresh_token(authentication_code)
		# curl -v https://api.sandbox.paypal.com/v1/identity/openidconnect/tokenservice \
		# -u "<Client-Id>:<Secret>" \
		# -d "grant_type=refresh_token
		#     &refresh_token=<Refresh-Token>"

		ret = {}
		client_id = PAYPAL_CLIENT_ID
		secret = PAYPAL_SECRET
		begin
	    call_url = "https://#{client_id}:#{secret}@api.sandbox.paypal.com/v1/identity/openidconnect/tokenservice"
	    call_url += "?grant_type=authorization_code&code=#{authentication_code}"
	    call_url += "&redirect_uri=" + PAYPAL_REDIRECT_URL

			conn = Faraday.new(:url => call_url) do |faraday|
			  faraday.request  :url_encoded             
			  faraday.response :logger                  
			  faraday.adapter  Faraday.default_adapter  
			end
			response = conn.post do |req|
	      req.url ""
	      req.headers['Content-Type'] = "application/x-www-form-urlencoded"
	    end
	    Rails.logger.info("get_refresh_token response.body: #{response.body}")

	    response = JSON.parse(response.body)

	    puts "response!!!!!!!!!!!!!!"
	    puts response['body'].inspect
	    if response['resfresh_token'].blank?
	    	ret['refresh_token'] = response['refresh_token']
	    	ret['access_token'] = response['access_token']
	    	ret['email']  = PaypalPayment.get_user_info(ret['access_token'])
	    else
	    	ret = response
	    end

		rescue Exception => ex
			Rails.logger.error("get_refresh_token: error #{ex.inspect }")
			ret['error'] = 	ex.inspect
		end

    ret
	end

	def self.get_access_token(refresh_token)
		#curl -v https://api.sandbox.paypal.com/v1/identity/openidconnect/tokenservice \
		# -u "<Client-Id>:<Secret>" \
		# -d "grant_type=refresh_token
		#     &refresh_token=<Refresh-Token>"

		#"refresh_token": "-xckIcDRpc-7ae8m3YhNIVQP9MxuFisIwIyl8bHOuIjWS-o4VG2M9uXo3b0qMBFmCYs9nNwLrpckOI0p2yMEiDUuepU"
		
		ret = ''
		client_id = PAYPAL_CLIENT_ID
		secret = PAYPAL_SECRET
		begin
	    call_url = "https://#{client_id}:#{secret}@api.sandbox.paypal.com/v1/identity/openidconnect/tokenservice"
	    call_url += "?grant_type=refresh_token&refresh_token=#{refresh_token}"

			conn = Faraday.new(:url => call_url) do |faraday|
			  faraday.request  :url_encoded             
			  faraday.response :logger                  
			  faraday.adapter  Faraday.default_adapter  
			end
			response = conn.post do |req|
	      req.url ""
	      req.headers['Content-Type'] = "application/x-www-form-urlencoded"
	    end
	    Rails.logger.info("get_access_token response.body: #{response.body}")

	    if !response.body.blank?
	    	json_body = JSON.parse(response.body)
	    	Rails.logger.info("get_access_token json_body: #{json_body.inspect}")
	    	puts "get_access_token json_body !!!!!!!!!!!!"
	    	puts json_body.inspect

	    	ret = json_body['access_token'] if json_body['access_token']    
	    end

		rescue Exception => ex
			Rails.logger.error("get_access_token: error #{ex.inspect }")
		end

    ret

	end



  def self.get_user_info(access_token)
    # curl -v https://api.sandbox.paypal.com/v1/identity/openidconnect/userinfo/?schema=openid \
		# -H "Content-Type:application/json" \
		# -H "Authorization: Bearer <Access-Token>"

		ret = ''
		call_url = "https://api.sandbox.paypal.com/v1/identity/openidconnect/userinfo/?schema=openid"
		begin
			conn = Faraday.new(:url => call_url) do |faraday|
			  faraday.request  :url_encoded             
			  faraday.response :logger                  
			  faraday.adapter  Faraday.default_adapter  
			end
			response = conn.get do |req|
	      req.url ""
	      req.headers['Content-Type'] = "application/json"
	      req.headers['Authorization'] = "Bearer #{access_token}"
	    end
	    Rails.logger.info("get_user_info response: #{response.inspect}")

	    puts "!!!!!!!response"
	    puts response.inspect
	    puts "==============="

	    if !response.body.blank?
	    	json_body = JSON.parse(response.body)
	    	Rails.logger.info("get_user_info json_body: #{json_body.inspect}")

	    	ret = json_body['email'] if json_body['email']    
	    end
			
		rescue Exception => e
			Rails.logger.error("get_user_info: error #{e.inspect }")
		end
   
    ret

  end

	def self.create_payment(access_token, total)
		# curl -v https://api.sandbox.paypal.com/v1/payments/payment \
		# -H 'Content-Type: application/json' \
		# -H 'Authorization: Bearer {accessToken}' \
		# -d '{
		#   "intent":"sale",
		#   "redirect_urls":{
		#     "return_url":"http://<return URL here>",
		#     "cancel_url":"http://<cancel URL here>"
		#   },
		#   "payer":{
		#     "payment_method":"paypal"
		#   },
		#   "transactions":[
		#     {
		#       "amount":{
		#         "total":"7.47",
		#         "currency":"USD"
		#       },
		#       "description":"This is the payment transaction description."
		#     }
		#   ]
		# }'

		# {
		#   "token_type": "Bearer",
		#   "expires_in": "900",
		#   "refresh_token": "-xckIcDRpc-7ae8m3YhNIVQP9MxuFisIwIyl8bHOuIjWS-o4VG2M9uXo3b0qMBFmCYs9nNwLrpckOI0p2yMEiDUuepU",
		#   "id_token": "A011Cg0AZjDJXEVdCi.aeO1EjPOdWMhAAgUhYHwb.fvuc8w",
		#   "access_token": "A015hZkqJ-Y-GmCyfqgq6VA9qoyLXrVbJuRH9ztmvMoV.LE"
		# }

		puts "access_token = #{access_token.inspect}"
		puts "total = #{total.inspect}"
		ret = {}
		total = ActionController::Base.helpers.number_to_currency(total, unit: '')
		call_url = "https://api.sandbox.paypal.com/v1/payments/payment"
		begin
			payment_params = {
				
				:intent => "sale",
				:payer => {
				:payment_method => "paypal" },
				:redirect_urls => {
				:return_url => "http://doctor-app.herokuapp.com/payment/execute",
				:cancel_url => "http://doctor-app.herokuapp.com/" },
				:transactions => [ {
				:amount => {
				:total => total,
				:currency => "GBP" },
				:description => "creating a payment" } ] 
			}

			puts "===================="
			puts "payment_params = #{payment_params.to_json.inspect}"
			puts "===================="

			conn = Faraday.new(:url => call_url) do |faraday|
			  faraday.request  :url_encoded             
			  faraday.response :logger                  
			  faraday.adapter  Faraday.default_adapter  
			end

			response = conn.post do |req|
	      req.url ""
	      req.headers['Content-Type'] = "application/json"
	      req.headers['Authorization'] = "Bearer #{access_token}"
	      req.body = payment_params.to_json
	    end
	    Rails.logger.info("create_payment response: #{response.inspect}")

	    puts "!!!!!!!response"
	    puts response.inspect
	    puts "==============="

	    if !response.body.blank?
	    	json_body = JSON.parse(response.body)
	    	Rails.logger.info("create_payment json_body: #{json_body.inspect}")
	    	puts "--------------------------------"
	    	puts "json_body = #{json_body.inspect}"
	    	puts "--------------------------------"

	    	ret['payment_id'] = json_body['id'] if json_body['id']
	    	ret['status'] = json_body['state'] if json_body['state']
	    	ret['amount'] = json_body['transactions'].first['amount']['total'].to_f if json_body['transactions'].first.present?
	    	ret['currency'] = json_body['transactions'].first['amount']['currency'] if json_body['transactions'].first.present?
	    end
			
		rescue Exception => e
			Rails.logger.error("create_payment: error #{e.inspect }")
		end
   
    ret

	end


  def self.capture_payment(access_token, total)
	
		puts "access_token = #{access_token.inspect}"
		puts "total = #{total.inspect}"
		ret = {}
		total = ActionController::Base.helpers.number_to_currency(total, unit: '')
		call_url = "https://api.sandbox.paypal.com/v1/payments/payment"
		begin
			payment_params = {
				
				:intent => "authorize",
				:payer => {
				:payment_method => "paypal" },
				:redirect_urls => {
				:return_url => "http://doctor-app.herokuapp.com/payment/execute",
				:cancel_url => "http://doctor-app.herokuapp.com/" },
				:transactions => [ {
				:amount => {
				:total => total,
				:currency => "GBP" },
				:description => "creating a payment" } ] 
			}

			puts "===================="
			puts "payment_params = #{payment_params.to_json.inspect}"
			puts "===================="

			conn = Faraday.new(:url => call_url) do |faraday|
			  faraday.request  :url_encoded             
			  faraday.response :logger                  
			  faraday.adapter  Faraday.default_adapter  
			end

			response = conn.post do |req|
	      req.url ""
	      req.headers['Content-Type'] = "application/json"
	      req.headers['Authorization'] = "Bearer #{access_token}"
	      req.body = payment_params.to_json
	    end
	    Rails.logger.info("capture_payment response: #{response.inspect}")

	    puts "!!!!!!!response"
	    puts response.inspect
	    puts "==============="

	    if !response.body.blank?
	    	json_body = JSON.parse(response.body)
	    	Rails.logger.info("capture_payment json_body: #{json_body.inspect}")
	    	puts "--------------------------------"
	    	puts "json_body = #{json_body.inspect}"
	    	puts "--------------------------------"

	    	ret['payment_id'] = json_body['id'] if json_body['id']
	    	ret['status'] = json_body['state'] if json_body['state']
	    	ret['amount'] = json_body['transactions'].first['amount']['total'].to_f if json_body['transactions'].first.present?
	    	ret['currency'] = json_body['transactions'].first['amount']['currency'] if json_body['transactions'].first.present?
	    	
	    	ret['authorization_id'] = json_body['transactions'].first['related_resources'].first['authorization']['id'] if json_body['transactions'].first.present?
	    end
			
		rescue Exception => e
			Rails.logger.error("capture_payment: error #{e.inspect }")
		end
   
    ret

	end

	def self.final_capture_payment(authorization_id, access_token, total, is_final=false)
	
		puts "authorization_id = #{authorization_id.inspect}"
		puts "access_token = #{access_token.inspect}"
		puts "total = #{total.inspect}"
		ret = {}
		total = ActionController::Base.helpers.number_to_currency(total, unit: '')
		call_url = "https://api.sandbox.paypal.com/v1/payments/authorization/#{authorization_id}/capture"
		begin
			payment_params = {
				:amount => {
				  :total => total,
				  :currency => "GBP" },
				:is_final_capture => is_final			  
			}

			puts "===================="
			puts "payment_params = #{payment_params.to_json.inspect}"
			puts "===================="

			conn = Faraday.new(:url => call_url) do |faraday|
			  faraday.request  :url_encoded             
			  faraday.response :logger                  
			  faraday.adapter  Faraday.default_adapter  
			end

			response = conn.post do |req|
	      req.url ""
	      req.headers['Content-Type'] = "application/json"
	      req.headers['Authorization'] = "Bearer #{access_token}"
	      req.body = payment_params.to_json
	    end
	    Rails.logger.info("final_capture_payment response: #{response.inspect}")

	    puts "!!!!!!!response"
	    puts response.inspect
	    puts "==============="

	    if !response.body.blank?
	    	json_body = JSON.parse(response.body)
	    	Rails.logger.info("capture_payment json_body: #{json_body.inspect}")
	    	puts "--------------------------------"
	    	puts "json_body = #{json_body.inspect}"
	    	puts "--------------------------------"
	    	if json_body['id']
		    	ret['payment_id'] = json_body['id'] 
		    	ret['status'] = json_body['state'] if json_body['state']
		    	ret['amount'] = total
		    	ret['currency'] = "GBP"
		    else
		    	ret['name'] = json_body['name'] 
		    	ret['message'] = json_body['message'] if json_body['message']
		    	ret['amount'] = total
		    	ret['currency'] = "GBP"
		    end
	    	
	    end
			
		rescue Exception => e
			Rails.logger.error("final_capture_payment: error #{e.inspect }")
		end
   
    ret

	end



end

