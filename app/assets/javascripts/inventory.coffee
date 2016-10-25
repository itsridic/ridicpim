$('.inventory.index').ready ->
  $('#inventory-table').DataTable
    paging: false
    fixedHeader: true
  $('.paginate_button').addClass 'btn btn-primary'
  $('.dataTable').on 'scroll', ->
    $('.dataTable').scrollTop $(this).scrollTop()
    return
  return