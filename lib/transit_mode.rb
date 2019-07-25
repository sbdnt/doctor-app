module TransitMode
  def self.call_transit(origins, destinations, transit="transit")
    # Note: Only run for one origin and multi-destinations, maximum is 25 destinations, or it will get over_querry_limit error
    key_list = ["AIzaSyAcLmYxUWJHqR6kq0OqVsfce770f5IxrO0","AIzaSyD3bUwLTXWKSt5f9MGH81KfEoRCaNtXrck","AIzaSyCle4g0Atf1qv0t-lkTQ5Kii5pCPS7QPwc","AIzaSyBqaopsszd3jgYiqQvZEVB16C4qOow5VAg"]
    api_key = key_list[0]
    limit = 0
    result = {}

    sleep 0.1
    res = RestClient.get "https://maps.googleapis.com/maps/api/distancematrix/json", {:params => {:origins => origins,
                                                                                                  :destinations => destinations,
                                                                                                  :mode => transit,
                                                                                                  :key => api_key}}

    res = JSON.parse(res)
    puts " ON LIB#{res.inspect}"

    is_response = false
    no_transit_result = false
    if res.present? && res['rows'].present? && res['rows'].first.present?
      is_response = true
      if res['rows'].first['elements'][0]['status'] == 'ZERO_RESULTS' && transit == "transit"
        no_transit_result = true
      end
    end

    failed_status = ['OVER_QUERY_LIMIT', 'REQUEST_DENIED']
    while ( res.present? && failed_status.include?(res['status']) || no_transit_result ) && limit < 3 do

      limit += 1
      if no_transit_result
        transit = 'driving'
      else
        api_key = key_list[limit]
      end
      sleep 0.1
      res = RestClient.get "https://maps.googleapis.com/maps/api/distancematrix/json", {:params => {:origins => origins,
                                                                                                    :destinations => destinations,
                                                                                                    :mode => transit,
                                                                                                    :key => api_key}}

      res = JSON.parse(res)
    end 

    destinations.split('|').each_with_index do |destination, index|
      km = 0
      durations = 0
      no_result = nil
      if is_response
        if res['rows'].first['elements'][index]['status'] == 'OK'
          km = res['rows'].first['elements'][index]["distance"]["value"].to_f / 1000
          durations = res['rows'].first['elements'][index]["duration"]["value"].to_f
          no_result = false
        end
        
        if res['rows'].first['elements'][index]['status'] == 'ZERO_RESULTS'
          no_result = true
        end
      end
      
      result[index] = {km: km, durations: durations, no_result: no_result}
    end
    result                                                                                 
  end
end