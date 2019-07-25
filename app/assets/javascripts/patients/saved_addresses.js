// Author: Thanh
$(document).ready(function() {
  var location_address = document.getElementById("location_address");
  var location_address_class = document.getElementsByClassName("saved-address");
  function initAutocompleteSavedAdress() {
    // Create the autocomplete object, restricting the search to geographical
    // location types.
    autocomplete = new google.maps.places.Autocomplete(
        (location_address),
        {types: ['geocode']});

    // When the user selects an address from the dropdown, populate the address
    // fields in the form.
    autocomplete.addListener('place_changed', fillInSavedAddress);

    // Clear latitude and longitude if address blank
    if($("#location_address").val() === "") {
      $("#location_latitude").val("");
      $("#location_longitude").val("");
    }
  }

  function fillInSavedAddress() {
    // Get the place details from the autocomplete object.
    var place = autocomplete.getPlace();
    var lat = place.geometry.location.G.toFixed(8);
    var lng = place.geometry.location.K.toFixed(8);
    $("#location_latitude").val(lat);
    $("#location_longitude").val(lng);
  }
  if (location_address && location_address_class.length > 0) {
    google.maps.event.addDomListener(window, 'load', initAutocompleteSavedAdress);

    // Prevent form auto submit when enter billing address via dropdown list
    google.maps.event.addDomListener(location_address, 'keydown', function(e) { 
      if (e.keyCode == 13) { 
        e.preventDefault(); 
      }
    });
  }
});