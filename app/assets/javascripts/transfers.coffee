$('.transfers.new, .transfers.edit').ready ->
  $('.modal').on 'shown.bs.modal', (e) ->
    $('form[data-validate]').enableClientSideValidations()

$('.transfers.index').ready ->
  $('.modal').on 'shown.bs.modal', (e) ->
    $(':input', '#new_transfer').not(':button, :submit, :reset, :hidden').val('').removeAttr('checked').removeAttr 'selected'
    $('form[data-validate]').enableClientSideValidations()
