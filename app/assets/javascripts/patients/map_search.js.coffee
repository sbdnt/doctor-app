class window.Search
  constructor: ->
    @placeSearch = undefined
    @autocomplete = undefined
    @componentForm()
    @initialize()
    @fillInAddress()
    @geolocate()

  componentForm: => 
    street_number: 'short_name'
    route: 'long_name'
    locality: 'long_name'
    administrative_area_level_1: 'short_name'
    country: 'long_name'
    postal_code: 'short_name'

  initialize: =>
    # Create the autocomplete object, restricting the search
    # to geographical location types.
    self = this
    autocomplete = new (google.maps.places.Autocomplete)(document.getElementById('autocomplete'), types: [ 'geocode' ])
    # When the user selects an address from the dropdown,
    # populate the address fields in the form.
    google.maps.event.addListener autocomplete, 'place_changed', ->
      self.fillInAddress()
      return
    return

  fillInAddress: =>
    # Get the place details from the autocomplete object.
    place = autocomplete.getPlace()
    for component of componentForm
      document.getElementById(component).value = ''
      document.getElementById(component).disabled = false
    # Get each component of the address from the place details
    # and fill the corresponding field on the form.
    i = 0
    while i < place.address_components.length
      addressType = place.address_components[i].types[0]
      if componentForm[addressType]
        val = place.address_components[i][componentForm[addressType]]
        document.getElementById(addressType).value = val
      i++
    return

  
  geolocate: =>
    if navigator.geolocation
      navigator.geolocation.getCurrentPosition (position) ->
        geolocation = new (google.maps.LatLng)(position.coords.latitude, position.coords.longitude)
        circle = new (google.maps.Circle)(
          center: geolocation
          radius: position.coords.accuracy)
        autocomplete.setBounds circle.getBounds()
        return
    return
