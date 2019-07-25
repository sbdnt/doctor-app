GoogleDistanceMatrix.default_configuration do |config|
  config.mode = 'transit'
  config.avoid = ['tolls']

  # To build signed URLs to use with a Google Business account
  config.google_business_api_client_id = "707369334881-gerq68mc6648racofoc18mcuovdtkknd.apps.googleusercontent.com"
  config.google_business_api_private_key = "AIzaSyD6EgymL4PKsEqwlj7txVhF_62sfwtGhGA"
  # config.google_business_api_client_id = "284352200989-62c4e5rnket6jtlj2ja0vk31c4edkja2.apps.googleusercontent.com"
  # config.google_business_api_private_key = "AIzaSyCle4g0Atf1qv0t-lkTQ5Kii5pCPS7QPwc" #tan.thang
  # config.google_business_api_client_id = "634810571477-dbpuflhfi7fja2g3bd7juocghpst1678.apps.googleusercontent.com"
  # config.google_business_api_private_key = "AIzaSyAcLmYxUWJHqR6kq0OqVsfce770f5IxrO0" #gpdq
  # config.google_business_api_private_key = "AIzaSyD3bUwLTXWKSt5f9MGH81KfEoRCaNtXrck" #gacon266gl
  
end