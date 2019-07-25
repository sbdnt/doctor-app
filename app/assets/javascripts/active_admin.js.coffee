#= require active_admin/base
#= require select2.min.js
#= require jquery_nested_form
#= require bootstrap.min

$(document).on 'ready page:load', ->
  tinyMCE.init({
     selector: ".txt_area"
     mode: 'textareas',
     plugins: ["link", "code", "preview", "fullscreen", "textcolor"],
     toolbar: "undo redo | styleselect | forecolor backcolor | bold italic | link image | fullscreen | preview | bullist | numlist",
  })
  #Init bootstrap tooltip
  $('[data-toggle="tooltip"]').tooltip({
    placement : 'bottom',
    html: true
  })

  #Align inline all checkbox label
  $(".logged_in label").each ->
    if $(this).has("input[type='checkbox']").length > 0
      $(this).addClass("label-fix-inline")
      $(this).children().addClass("checkbox-fix-inline")
  #Init select2
  $(".zone-select2").select2({
    placeholder: "Choose zone"
  })
  $(".time-unit-select2").select2({
    placeholder: "Choose time-unit"
  })
  $(".patient-select2").select2({
    placeholder: "Choose patient"
  })
  #Hide reason textarea if doctor approved(first time on load edit doctor page)
  if $("#doctor_status_input #doctor_status_approved").first().is(':checked') || !$("#doctor_status_input #doctor_status_rejected").first().is(':checked')
    $('#doctor_reason_input').hide()
  #Hide reason textarea if agency approved(first time on load edit doctor page)
  if $("#agency_status_input #agency_status_approved").first().is(':checked') || $("#agency_status_input #agency_status_rejected").first().is(':checked')
    $('#agency_reason_input').hide()

  $("#doctor_status_input input[type='radio']").change (e)->
    if e.currentTarget.value == 'approved'
      $('#doctor_reason_input').hide()
      $('#doctor_reason_input textarea').val("")
    else
      $('#doctor_reason_input').show()
  $("#agency_status_input input[type='radio']").change (e)->
    if e.currentTarget.value == 'approved'
      $('#agency_reason_input').hide()
      $('#agency_reason_input textarea').val("")
    else
      $('#agency_reason_input').show()

  $(document).on 'click', '.has_many_add', (e) ->
    if $(".zone-select2").length > 0
      $(".zone-select2").select2({
        placeholder: "Choose cover"
      })
    $(".logged_in label").each ->
      if $(this).has("input[type='checkbox']").length > 0
        $(this).addClass("label-fix-inline")
        $(this).children().addClass("checkbox-fix-inline")

  nested_parent_field = $('.header-item').find('.has_nested')
  if nested_parent_field.length > 0
    $.each nested_parent_field, (index, value) ->
      $(value).addClass('dropdown')
      current = $(value).find('.current')
      current.removeClass('current')
      dropdown = $(value).children().first()
      dropdown.attr('data-toggle', 'dropdown')
      dropdown.attr('aria-haspopup', 'true')
      dropdown.attr('aria-expanded', 'false')
      dropdown.attr('id', 'dLabel'+index)
      dropdown.append("<span class='caret'></span>")
      downmenu = $(value).find('ul')
      downmenu.addClass('dropdown-menu')
      downmenu.attr('role','menu')
      downmenu.attr('aria-labelledby','dLabel'+index)
      dropdown.dropdown()

  $(document).on "change", 'select.zone-select2.price-category',(e) ->
    console.log(111111)
    id_name = $(this).attr('id')
    price_category_id = $(this).val()
    console.log(id_name)
    console.log(price_category_id)
    $.ajax
      type: "GET"
      url: "/invoices/get_price_items"
      data:
        price_category_id: price_category_id
        id_name: id_name
      dataType: "json"

      success: (data) ->
        console.log(2222)
        $('#' + data['id_name']).empty().select2({
          data: data['item_lists']
        });
        $.ajax
          type: "GET"
          url: "/invoices/get_item_price"
          data:
            price_item_id: parseInt($('#' + data['id_name']).val())
          dataType: "json"

          success: (data1) ->
            $('#' + data['id_name']).parent().next().children().val(data1['price'])

          error: (errors, status) ->
      error: (errors, status) ->

  $(document).on "change", 'select.zone-select2.price_items',(e) ->
    $.ajax
      type: "GET"
      url: "/invoices/get_item_price"
      data:
        price_item_id: parseInt($(e.target).val())
      dataType: "json"

      success: (data) ->
        console.log($(e.target).parent().next().children().next())
        $(e.target).parent().next().children().next().val(data['price'])

      error: (errors, status) ->

  $('input.hasDatetimePicker').datepicker
    dateFormat: 'yy/mm/dd'
    beforeShow: ->
      setTimeout (->
        $('#ui-datepicker-div').css 'z-index', '3000'
        return
      ), 100
      return




