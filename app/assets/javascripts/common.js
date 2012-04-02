$(document).ready(function() {
    $('#subscribe-email-submit').hover(function() {
        $(this).attr('src', '/images/ok-button-hover.png');
    }, function() {
        $(this).attr('src', '/images/ok-button.png');
    });
    
    $('#subscribe-form').submit(function(e) {
        e.preventDefault();
        
        $.post('/subscribe', {email: $('#subscribe-email').val()}, function() {
            $('#subscribe-email-submit').replaceWith('<img src="/images/ticked-button.png" alt="Subscribed" id="email-subscribed" />');
        });
    });
});