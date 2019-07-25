class window.Calendar
  constructor: ->
    @clickSelectAllCheckboxes()

  clickSelectAllCheckboxes: ->
    $(".apply-schedule").delegate ".select_all", "click", (event)=>
      target = $(event.target)
      if target.is(":checked")
        $(".apply-in-week").find("input[type='checkbox'][class!='select_all']").prop('checked', true)
        $(".btn-week").removeClass("disabled")
        $(".btn-day").addClass("disabled")
        $('#start_time').attr("value", localStorage["start_time_week"])
        $('#end_time').attr("value", localStorage["end_time_week"])
      else
        $(".apply-in-week").find("input[type='checkbox'][class!='select_all']").prop('checked', false)
        $(".btn-week").addClass("disabled")
        $(".btn-day").addClass("disabled")
    

