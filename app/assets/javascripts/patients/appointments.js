$(document).ready(function() {
  $('.btn-apply-voucher-code').click(function(e) {
    e.preventDefault();
    var voucher_code = $("#voucher_code").val();
    $.ajax({
      method: "GET",
      url: "/vouchers/" + voucher_code + "/validate"
    })
      .done(function(obj){
        $("#voucher-valid-message").removeClass().text(obj.message).addClass(obj.status);
      });
  });

  $("#voucher_code").on('input', function(e) {
    if($(this).val().length > 0) {
      $('.btn-apply-voucher-code').removeClass('disabled');
    }
    else {
      $('.btn-apply-voucher-code').addClass('disabled');
    }
  });

  if($("#voucher_code").length > 0) {
    $('.btn-apply-voucher-code').removeClass('disabled');
  }

  // var pos = new google.maps.LatLng(10.8064534, 106.696984);

  function initAppointmentMap() {
    var lat = parseFloat(document.getElementById('appointment_lat').value);
    var lng = parseFloat(document.getElementById('appointment_lng').value);
    var myLatLng = { lat: lat, lng: lng };

    var map = new google.maps.Map(document.getElementById('appointment-map'), {
      zoom: 16,
      center: myLatLng
    });

    var marker = new google.maps.Marker({
      position: myLatLng,
      map: map,
      icon: "/assets/patient_marker.png"
    });
  }

  if($("#appointment-map").length > 0) {
    google.maps.event.addDomListener(window, 'load', initAppointmentMap);
  }

  // Author: Thanh
  function initTrackDoctorMap() {
    var lat = parseFloat(document.getElementById('doctor_latitude').value);
    var lng = parseFloat(document.getElementById('doctor_longitude').value);
    var myLatLng = { lat: lat, lng: lng };

    var map = new google.maps.Map(document.getElementById('track-doctor-map'), {
      zoom: 16,
      center: myLatLng
    });

    var marker = new google.maps.Marker({
      position: myLatLng,
      map: map,
      icon: "/assets/patient_marker.png"
    });
  }

  if($("#track-doctor-map").length > 0) {
    google.maps.event.addDomListener(window, 'load', initTrackDoctorMap);
  }
});