$('.adjustments.new, .adjustments.edit').ready ->
  $('.modal').on 'shown.bs.modal', (e) ->
    $('form[data-validate]').enableClientSideValidations()
    $('.edit_adjustment_user_date').datetimepicker theme: 'dark'
    return
  return

$('.adjustments.index').ready ->
  $('.choose-product option').each ->
    ttext = $(this).text().slice(0, 65)
    console.log ttext
    $(this).text ttext
    return
  $('.adjustment-type option').each ->
    ttext = $(this).text().slice(0, 35)
    $(this).text ttext
    return
  $('.choose-product').select2()
  $('.adjustment-type').select2()
  $('.choose-product').change ->
    setTimeout ->
      $('.choose-product').focus()
      return
    return
  $('.adjustment-type').change ->
    setTimeout ->
      $('.adjustment-type').focus()
      return
    return
  $('.modal').on 'shown.bs.modal', (e) ->
    $(':input', '#new_adjustment').not(':button, :submit, :reset, :hidden').val('').removeAttr('checked').removeAttr 'selected'
    $('form[data-validate]').enableClientSideValidations()
    $('#adjustment_user_date').datetimepicker theme: 'dark'
    return
  $(':input', '#new-adjustment-form').not(':button, :submit, :reset, :hidden').val ''
  return

