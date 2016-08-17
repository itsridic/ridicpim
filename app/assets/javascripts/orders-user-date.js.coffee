$(document).ready ->
  return unless $(".new-order-form").length > 0
  $(".order_user_date").hide()
  $("#adduserdate").on "click", ->
    $(".order_user_date").toggle()
    if $("#adduserdate").text() == "Add Date"
      $("#adduserdate").text("Hide Date")
    else
      $("#adduserdate").text("Add Date")
