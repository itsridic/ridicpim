$(".orders.new, .orders.edit").ready(function() {
  $(".order_user_date").hide();
  $("#adduserdate").on("click", function() {
    $(".order_user_date").toggle();
    if ($("#adduserdate").text() == "Add Date") {
      $("#adduserdate").text("Hide Date");
    }
    else {
      $("#adduserdate").text("Add Date");
    }
  });  
  $("#order_user_date").datetimepicker({
    theme: "dark"
  });
  $(".modal").on("shown.bs.modal", function(e) {
    $(":input","#new_product").not(":button, :submit, :reset, :hidden").val("").removeAttr("checked").removeAttr("selected");
    $("form[data-validate]").enableClientSideValidations();
  });    
});

$(".orders.new").ready(function() {
  $(".order-product").select2();
  $(".order-quantity").last().focus();
  $(document).on('change', '.order-product', function() {
    var text = $(".order-product option:selected").text();
    if(text) {
      if(text.match(/Choose/)) {
        if(text.match(/Choose/g).length === 1) {
          $(".add_fields").click();
          $(".order-product").select2();
          $(".order-quantity").last().focus();
        }
      } else {
        $(".order-product").select2();
        $(".order-quantity").last().focus();
      }
    }
   });
});

