$('.contacts.new, .contacts.edit').ready ->
  $('.modal').on 'shown.bs.modal', (e) ->
    $('form[data-validate]').enableClientSideValidations()
    return
  return
  
$('.contacts.index').ready ->
  $('.spinner').hide()
  $('.modal').on 'shown.bs.modal', (e) ->
    $(document).off '.fetchContacts'
    $(':input', '#new_contact').not(':button, :submit, :reset, :hidden').val('').removeAttr('checked').removeAttr 'selected'
    $('form[data-validate]').enableClientSideValidations()
    return
  $('#fetch-contacts').click ->
    $(document).on 'ajaxStart.fetchContacts', ->
      $('.spinner').show()
      return
    $(document).on 'ajaxStop.fetchContacts', ->
      $('.spinner').hide()
      location.reload()
      return
    return
  return
