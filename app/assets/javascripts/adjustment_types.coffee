$('.adjustment_types.new, .adjustment_types.edit').ready ->
  $('.modal').on 'shown.bs.modal', (e) ->
    $('form[data-validate]').enableClientSideValidations()
    return
  return

$('.adjustment_types.index').ready ->
  $('.modal').on 'shown.bs.modal', (e) ->
    $(':input', '#new_adjustment_type').not(':button, :submit, :reset, :hidden').val('').removeAttr('checked').removeAttr 'selected'
    $('form[data-validate]').enableClientSideValidations()
    return
  return
  