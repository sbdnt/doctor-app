$(document).ready(function() {
  $('#credit_card_form').card({
    // a selector or DOM element for the container
    // where you want the card to appear
    container: '.card-wrapper', // *required*
    formSelectors: {
      numberInput: 'input#patient_credit_payment_cc_num',
      expiryInput: 'input#patient_credit_payment_expiry',
      cvcInput: 'input#patient_credit_payment_cvc'
    },
    placeholders: {
      number: '•••• •••• •••• ••••',
      expiry: '••/••',
      cvc: '•••'
    }
    // all of the other options from above
  });

  var credit_card_bill_address_input = document.getElementById("patient_credit_payment_bill_address");
  function initAutocompleteBillingAdress() {
    // Create the autocomplete object, restricting the search to geographical
    // location types.
    autocomplete = new google.maps.places.Autocomplete(
        (credit_card_bill_address_input),
        {types: ['geocode']});

    // When the user selects an address from the dropdown, populate the address
    // fields in the form.
    autocomplete.addListener('place_changed', fillInBillingAddress);
  }

  function fillInBillingAddress() {
    // Get the place details from the autocomplete object.
    var place = autocomplete.getPlace();
    var lat = place.geometry.location.G.toFixed(8);
    var lng = place.geometry.location.K.toFixed(8);
    $("#patient_credit_payment_lat_bill_address").val(lat);
    $("#patient_credit_payment_lng_bill_address").val(lng);
  }
  if (credit_card_bill_address_input) {
    google.maps.event.addDomListener(window, 'load', initAutocompleteBillingAdress);

    // Prevent form auto submit when enter billing address via dropdown list
    google.maps.event.addDomListener(credit_card_bill_address_input, 'keydown', function(e) { 
      if (e.keyCode == 13) { 
        e.preventDefault(); 
      }
    });
  }

  $(".show-bill-addresses").focus(function(e) {
    $(".credit-card-last-bill-addresses").slideDown("1000");
  });

  $(".credit-card-bill-address").on('click', function(e) {
    var $input = $(this);
    $("#patient_credit_payment_bill_address").val(($input.find('span:nth-child(1)').text()));
    $("#patient_credit_payment_lat_bill_address").val(($input.find('span:nth-child(2)').text()));
    $("#patient_credit_payment_lng_bill_address").val(($input.find('span:nth-child(3)').text()));
  });

});