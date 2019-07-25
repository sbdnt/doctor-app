$(document).on 'ready page:load', ->

  #Init select2
  $("#doctor_default_start_location").select2({
    placeholder: "Select zone"
  })
  $(".zone-select2").select2({
    placeholder: "Select zone"
  })

  $(".agency-select2").select2({
    placeholder: "None"
  })

  #Init datepicker
  $('.datepicker').datepicker({
    format: 'yyyy/mm/dd',
    autoclose: true,
    todayHighlight: true
  })

  #Upload photo preview
  $('form').delegate '.photo-upload', 'change', (e) ->
    input = $(e.currentTarget)
    file = input[0].files[0]
    if file != undefined
      fileExtension = ['jpeg', 'png', 'gif', 'jpg']
      if $.inArray($(e.target).val().split(".").pop().toLowerCase(), fileExtension) is -1
        alert "Only '.jpeg', '.png', '.gif', '.jpg' formats are allowed."
        $(input).val("")
        $(".image-preview-wrapper").hide()
      else
        currentPreview = input.parent().parent().next().children()
        console.log(currentPreview)
        reader = new FileReader()
        reader.onload = (e) ->
          image_base64 = e.target.result
          console.log(image_base64)
          $(".image-preview", currentPreview).attr "src", image_base64
        reader.readAsDataURL file
        currentPreview.show()

  #Upload file validate
  $('form').delegate '.file-upload', 'change', (e) ->
    input = $(e.currentTarget)
    file = input[0].files[0]
    if file != undefined
      fileExtension = ['pdf']
      if $.inArray($(e.target).val().split(".").pop().toLowerCase(), fileExtension) is -1
        alert "Only '.pdf' formats are allowed."
        $(input).val("")

$(document).on 'nested:fieldAdded', (event) ->
  # this field was just inserted into your form
  field = event.field
  dateField = field.find('.zone-select2')
  #Init select2
  dateField.select2({
    placeholder: "Choose cover"
  })

