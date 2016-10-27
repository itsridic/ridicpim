$('.adjustments.new, .adjustments.edit').ready ->
  $('.modal').on 'shown.bs.modal', (e) ->
    $('form[data-validate]').enableClientSideValidations()
    $('.edit_adjustment_user_date').datetimepicker theme: 'dark'

$('.adjustments.index').ready ->
  $('.choose-product option').each ->
    ttext = $(this).text().slice(0, 65)
    console.log ttext
    $(this).text ttext
  $('.adjustment-type option').each ->
    ttext = $(this).text().slice(0, 35)
    $(this).text ttext
  $('.choose-product').select2()
  $('.adjustment-type').select2()
  $('.adjustment-location').select2()
  $('.choose-product').change ->
    setTimeout ->
      $('.choose-product').focus()
  $('.adjustment-type').change ->
    setTimeout ->
      $('.adjustment-type').focus()
  $('.adjustment-location').change ->
    setTimeout ->
      $('.adjustment-location').focus()
  $('.modal').on 'shown.bs.modal', (e) ->
    $(':input', '#new_adjustment').not(':button, :submit, :reset, :hidden').val('').removeAttr('checked').removeAttr 'selected'
    $('form[data-validate]').enableClientSideValidations()
    $('#adjustment_user_date').datetimepicker theme: 'dark'
  $(':input', '#new-adjustment-form').not(':button, :submit, :reset, :hidden').val ''
