//
//= require jquery
//

$(document).ready(function() {
  $('.poster').click(function(e) {
    e.preventDefault();
    window.open(this.href, '_blank');
  });
});