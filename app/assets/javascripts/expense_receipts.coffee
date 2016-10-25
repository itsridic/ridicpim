$ ->
  if $('.pagination').length && $('#all-expense_receipts').length
    $(window).scroll ->
      url = $('.pagination .next_page').attr('href')
      if url && $(window).scrollTop() > $(document).height() - $(window).height() - 50
        $('.pagination').html('<i class="fa fa-spinner fa-spin" aria-hidden="true"></i>');
        $.getScript(url)
    $(window).scroll()

$('.expense_receipts.new, .expense_receipts.edit').ready ->

  toggleDate = ->
    $('.expense_receipt_user_date').toggle()
    if $('#adduserdate').text() == 'Add Date'
      $('#adduserdate').text 'Hide Date'
    else
      $('#adduserdate').text 'Add Date'
    return

  $('.expense_receipt_user_date').hide()
  addUserDate = document.getElementById('adduserdate')
  addUserDate.addEventListener 'click', toggleDate, false
  $('#expense_receipt_user_date').datetimepicker theme: 'dark'
  return
  
$('.expense_receipts.new').ready ->
  $('.add_fields').click()
  $(document).on 'change', '.choose-account', ->
    text = $('.choose-account option:selected').text()
    if text
      if text.match(/Choose/)
        if text.match(/Choose/g).length == 1
          $('.add_fields').click()
      else
        $('.add_fields').click()
    return
  return