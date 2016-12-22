$ ->
  if $('.pagination').length && $('#all-orders').length
    $(window).scroll ->
      url = $('.pagination .next_page').attr('href')
      if url && $(window).scrollTop() > $(document).height() - $(window).height() - 50
        $('.pagination').html('<i class="fa fa-spinner fa-spin" aria-hidden="true"></i>')
        $.getScript(url)
    $(window).scroll()

$('.products.new, .products.edit').ready ->
  $('.modal').on 'shown.bs.modal', (e) ->
    $('form[data-validate]').enableClientSideValidations()

$('.products.index').ready ->
  $('.spinner').hide()
  $('.spinner-mws').hide()
  $('.modal').on 'shown.bs.modal', (e) ->
    $(document).off '.fetchProducts'
    $(':input', '#new_product').not(':button, :submit, :reset, :hidden').val('').removeAttr('checked').removeAttr 'selected'
    $('form[data-validate]').enableClientSideValidations()
  $('#fetch-products').click ->
    $(document).on 'ajaxStart.fetchProducts', ->
      $('.spinner').show()
    $(document).on 'ajaxStop.fetchProducts', ->
      $('.spinner').hide()
      location.reload()
