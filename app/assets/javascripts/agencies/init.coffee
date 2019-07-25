$ ->
  window.calendar = new Calendar
$(document).on 'ready page:load', ->
  $(".main-loading").hide()
  $('[data-toggle="tooltip"]').tooltip({
    placement : 'bottom',
    html : true
  })