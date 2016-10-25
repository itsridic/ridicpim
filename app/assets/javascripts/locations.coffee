$('.locations.new, .locations.edit').ready ->
  $('.modal').on 'shown.bs.modal', (e) ->
    $('form[data-validate]').enableClientSideValidations()
    return
  return

$('locations.index').ready ->
  $('.modal').on 'shown.bs.modal', (e) ->
    $(':input', '#new_location').not(':button, :submit, :reset, :hidden').val('').removeAttr('checked').removeAttr 'selected'
    $('form[data-validate]').enableClientSideValidations()
    return
  return

  