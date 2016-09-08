(function() {
  $(function() {
    if ($('.pagination').length && $('#all-orders').length) {
      $(window).scroll(function() {
        var url;
        url = $('.pagination .next_page').attr('href');
        if (url && $(window).scrollTop() > $(document).height() - $(window).height() - 50) {
          $('.pagination').html('<i class="fa fa-spinner fa-spin" aria-hidden="true"></i>');
          return $.getScript(url);
        }
      });
      return $(window).scroll();
    }
  });

}).call(this);
