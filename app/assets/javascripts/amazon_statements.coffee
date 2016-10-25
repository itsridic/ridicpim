$('.amazon_statements.index').ready ->
  $('.spinner').hide()
  $(document).ajaxStart ->
    $('.spinner').show()
    return
  $(document).ajaxStop ->
    $('.spinner').hide()
    location.reload()
    return
  return