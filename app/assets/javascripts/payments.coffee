$('.payments.new, .payments.edit').ready ->
  $('.modal').on 'shown.bs.modal', (e) ->
    $('form[data-validate]').enableClientSideValidations()
    return
  return
$('.payments.index').ready ->
  $('.modal').on 'shown.bs.modal', (e) ->
    $(':input', '#new_payment').not(':button, :submit, :reset, :hidden').val('').removeAttr('checked').removeAttr 'selected'
    $('form[data-validate]').enableClientSideValidations()
    return
  return