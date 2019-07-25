class window.Map
  constructor: ->
    @getCurrentPos()
    @markers = []
    @clickEditLocation()
    @updateLocation()
    @chooseAddress()
    @manualSelectLocation()
    @clickOnSkip()

  getCurrentPos: =>
    if (typeof tab != 'undefined' && tab == "yes" && confirm_value != "true" && typeof(window.handler) != "undefined" && typeof(window.ib) != "undefined")
      console.log("CASE 1")
      if navigator.geolocation
        navigator.geolocation.getCurrentPosition ((position) ->
          console.log('CASE 1-1')
          getShareCurrentPosition(position.coords.latitude, position.coords.longitude)
          return
        ), (position)->
          getShareCurrentPosition(localStorage.getItem("lat"), localStorage.getItem("lng"))
          handleNoGeolocation true
          return
      else
        console.log('CASE 1-2')
        # Browser does not support Geolocation
        handleNoGeolocation false

    else if (typeof tab != 'undefined' && (tab == "skip" || tab == "no") && confirm_value != 'true')
      console.log("CASE 2")
      if navigator.geolocation
        navigator.geolocation.getCurrentPosition ((position) ->
          console.log('CASE 2-1-1')
          getShareCurrentPosition(position.coords.latitude, position.coords.longitude)
          return
        ), ->
          console.log('CASE 2-1-2')
          handleNoGeolocation true
          return
      else
        console.log('CASE 2-2')
        # Browser does not support Geolocation
        handleNoGeolocation false

    else if (typeof(confirm_value) != "undefined" && confirm_value == "true" && typeof(window.handler) != "undefined" && typeof(window.ib) != "undefined")
      console.log("CASE 3")
      if (typeof(current_address) != "undefined")

        $("#show-address").html(current_address)
        $(".address").removeClass("hidden")
        $("#location_address").val(current_address)
        localStorage.setItem("test", current_address)

      if (localStorage.getItem("check_logged") == "true")
        console.log("logged")
        console.log(lat)
        console.log(lng)
        pos = new (google.maps.LatLng)(lat, lng)
      else
        console.log("un-logged")
        pos = new (google.maps.LatLng)(localStorage.getItem("unlogged_lat"),localStorage.getItem("unlogged_lng"))

      myOptions = showContentInfoBox()
      ib.setOptions(myOptions)
      window.marker = new (google.maps.Marker)(
                map: window.handler.getMap()
                position: pos
                icon: "/assets/patient_marker.png"
               )
      ib.open window.handler.getMap(), marker
      window.handler.getMap().setCenter pos
      #window.handler.bounds.extendWith(map.markers)
      window.handler.fitMapToBounds()
      window.handler.getMap().setZoom(16)
    

  clickEditLocation: =>
    console.log("call click edit location")
    $(".btn-edit-location").click ()->
      window.location.href = "/patients/locations?tab="+tab+"&confirm="+confirm_value

  updateLocation: =>
    console.log("call update location")
    $(".btn-location-confirm").click () =>
      $(".form-update-location").submit()
      return

  chooseAddress: =>
    console.log("call choose address")
    $(".last-saved_address .select_address").click (e) ->
      if e.target.tagName == "DIV"
        address = $(e.target).next().text()
        lat = $(e.target).next().data('lat')
        lng = $(e.target).next().data('lng')
        set_billing = if $(e.target).next().next().children().hasClass('active') then true else false
      else
        address = $(e.target).parent().next().text()
        lat = $(e.target).parent().next().data('lat')
        lng = $(e.target).parent().next().data('lng')
        set_billing = if $(e.target).parent().next().next().children().hasClass('active') then true else false
      $("#location_address").val(address)
      localStorage.setItem("selectedLocation", true)
      localStorage.setItem("address", address)
      localStorage.setItem("choseAddress", JSON.stringify({'address': address, 'lat': lat, 'lng': lng, 'set_billing': set_billing}))
      tab = $("#tab").val();
      window.location.href = "/patients/maps?tab="+tab+"&confirm=true"
      return

  manualSelectLocation: =>
    window.res_marker = []
    if (typeof(window.handler) != "undefined") #&& tab == "no")
      google.maps.event.addListener window.handler.getMap(), 'click', (event) ->
        lat = event.latLng.lat()
        lng = event.latLng.lng()
        console.log('manual select')
        getAddressFromLatLng(lat, lng)
        clearAllMarker()
        $.ajax(
          url: "/patients/maps/find_and_show_doctor_around",
          data: {lat: lat, lng: lng}
        ).done (res)->
          if parseInt(res["min_eta"]) > 0
            if window.res_marker.length > 0
              window.res_marker = []
            localStorage.setItem("min_eta", res["min_eta"])
            #$(".circle.pull-left .min-eta").text(res["min_eta"])
            #$(".circle.pull-left .mins").text("MINS")

            $.each res["markers"], (index, value) ->
              pos = new (google.maps.LatLng)(value["lat"], value["lng"])
              new_marker = new (google.maps.Marker)(
                map: window.handler.getMap()
                position: pos
                icon: "/assets/doctor_marker.png"
              )
              window.res_marker.push(new_marker)
          else
            localStorage.setItem("min_eta", "")
            $.each objMap.markers, (index, value) ->
              value.setMap(null)
            if window.res_marker.length > 0
              $.each window.res_marker, (index, value) ->
                value.setMap(null)
            #$(".circle.pull-left .min-eta").text("")
            #$(".circle.pull-left .mins").text("")

          #Close old infoBox & create one with new position
          window.ib.close()
          pos = new (google.maps.LatLng)(lat, lng)
          window.marker.setPosition(pos)

          myOptions = showContentInfoBox()
          ib.setOptions(myOptions)
          ib.open window.handler.getMap(), marker

        return
      return

  clickOnSkip: =>
    $(".button-skip").click =>
      window.location.href = "/patients/maps?tab=no"

handleNoGeolocation = (errorFlag) ->
  if errorFlag
    content = 'Error: The Geolocation service failed.'
  else
    content = 'Error: Your browser doesn\'t support geolocation.'

  pos = new (google.maps.LatLng)(51.507351, -0.127758)
  window.handler.getMap().setCenter pos
  window.handler.fitMapToBounds()
  window.handler.getMap().setZoom(10)
  pos = new (google.maps.LatLng)(lat, lng)
  window.marker = new (google.maps.Marker)(
            map: window.handler.getMap()
            position: pos
            icon: "/assets/patient_marker.png"
           )
  return

buildMarker= (lat, lng, id, info, picture, title) ->
  {
    "lat": lat,
    "lng": lng,
    "id": id,
    "title": title,
    "picture":{"url": picture, "width":32, "height":32},
    "infowindow": info
  }
window.drawInfoWindow = (content, box_width) ->
  myOptions =
    content: content
    disableAutoPan: false
    maxWidth: 0
    pixelOffset: new (google.maps.Size)(-100, -33)
    zIndex: 9999
    boxStyle:
      backgroundColor: '#8660C7'
      opacity: 0.75
      width: box_width
      color: 'white'
      borderRadius: '15px'
      paddingTop: '2px'
      paddingLeft: '2px'
      paddingBottom: '2px'
      marginBottom: '7px'
    closeBoxMargin: '9px 6px 0px 2px'
    closeBoxURL: '/assets/arrow-right.png'
    infoBoxClearance: new (google.maps.Size)(1, 1)
    isHidden: false
    pane: 'floatPane'
    enableEventPropagation: false
    alignBottom: true

getAddressFromLatLng = (lat, lng) ->
  console.log(lat);
  console.log(lng);
  $.ajax(
    url: "https://maps.googleapis.com/maps/api/geocode/json?latlng="+lat+","+lng
    ).done (res)->
      console.log(res)
      if (res["status"] != "ZERO_RESULTS")
        window.address = res["results"][0]["formatted_address"]
        localStorage.setItem("address", address)
        $(".address").removeClass("hidden")
        $("#show-address").html(address)
        $("#location_address").val(address)
        #Add lat, lng to location submit form
        $("#location_lat").val(lat)
        $("#location_lng").val(lng)
        $("#show-address-unlogged").html(address)
        localStorage.setItem("choseAddress", JSON.stringify({'address': address, 'lat': lat, 'lng': lng, 'set_billing': false}));
      
    return

showContentInfoBox = () ->
  #if _.isEmpty(localStorage.getItem("arrived_time") || (localStorage.getItem("status") == "unbooking"))
  if localStorage.getItem("status") == "unbooking" || localStorage.getItem("status") == "" || localStorage.getItem("status") == null
    if localStorage.getItem("min_eta") != null && localStorage.getItem("min_eta") != ""
      mins = if parseInt(localStorage.getItem("min_eta")) > 1 then "<div class='mins'>MINS</div>" else "<div class='mins'>MIN</div>"
      circle = "<div class='circle pull-left'><div class='min-eta'>" + localStorage.getItem("min_eta") + "</div>" + mins + "</div>"
    else
      circle = "<div class='circle pull-left'><div class='min-eta'></div><div class='mins'></div></div>"
    if localStorage.getItem("selectedLocation") == 'true'
      href = "/patients/maps/life_threatening"
    else
      href = "/patients/locations?tab=" + tab
    content = circle + "<div class='pull-left text-window'><a class='text-window-link' href=" + href + ">SET LOCATION</a></div>"
    box_width = "180px"
  else
    if (localStorage.getItem("status") == "assigned")
      #content = "<div class='text-window'> EXPECTED GP ARRIVAL: "+localStorage.getItem("arrived_time")+"</div>"
      content = "<div class='text-window'> APPOINTMENT START: "+localStorage.getItem("arrived_time")+"</div>"
      box_width = "210px"
    else
      #content = "<div class='text-window'> APPOINTMENT START: "+localStorage.getItem("arrived_time")+"</div>"
      content = "<div class='text-window'> EXPECTED GP ARRIVAL: "+localStorage.getItem("arrived_time")+"</div>"
      box_width = "210px"

  myOptions = drawInfoWindow(content, box_width)
  return myOptions

getShareCurrentPosition = (lat, lng) ->
  pos = new (google.maps.LatLng)(lat, lng)

  myOptions = showContentInfoBox()
  
  ib.setOptions(myOptions)
  window.marker = new (google.maps.Marker)(
            map: window.handler.getMap()
            position: pos
            icon: "/assets/patient_marker.png"
           )
  ib.open window.handler.getMap(), marker

  getAddressFromLatLng(lat, lng)
  window.handler.getMap().setCenter pos
  window.handler.fitMapToBounds()
  window.handler.getMap().setZoom(16)
  $(".btn-next-step").removeClass("disabled")

clearAllMarker = ->
  $.each objMap.markers, (index, value) ->
    value.setMap(null)
  $.each window.res_marker, (index, value) ->
    value.setMap(null)



