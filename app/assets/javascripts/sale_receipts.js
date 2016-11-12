// Sales Receipts New
$(".sales_receipts.new, .sales_receipts.edit, .sales_receipts.create").ready(function() {
  $(".add_fields").click();
  $(".choose-product").select2();
  $(document).on('change', '.choose-product', function() {
    var text = $(".choose-product option:selected").text();
    if(text) {
      if(text.match(/Choose/)) {
        if(text.match(/Choose/g).length === 1) {
          $(".add_fields").click();
          $(".choose-product").select2();
          $(".sale-quantity").eq(-2).focus();
        }
      } else {
        $(".add_fields").click();
        $(".choose-product").select2();
        $(".sale-quantity").eq(-2).focus();
      }
    }
  });
  $("#sales_receipt_payment_id").change(function() {
    $(".choose-product").first().focus();
  })
});
// Sales Receipts _form
$(".sales_receipts.new, .sales_receipts.edit, .sales_receipts.create").ready(function() { 
  function toggleDate() { 
    $(".sales_receipt_user_date").toggle(); 
    if ($("#adduserdate").text() == "Add Date") { 
      $("#adduserdate").text("Hide Date"); 
    } else { 
      $("#adduserdate").text("Add Date"); 
    } 
  } 
  $(".sales_receipt_user_date").hide(); 
  var addUserDate = document.getElementById('adduserdate'); 
  addUserDate.addEventListener('click', toggleDate, false); 
  $("#sales_receipt_user_date").datetimepicker({
    theme: "dark"
  });
});