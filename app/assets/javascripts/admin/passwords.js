$(document).ready(function() {
    var $body = $('body');
    if (!$body.hasClass('passwords')) return;
    
    var $dialog
    
    $('.roles a').click(function(e) {
        e.preventDefault();
        
        $('.role-form').hide()
            .filter('#role-' + $(this).data('id')).show();
        
    });
});