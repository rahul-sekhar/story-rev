$(document).ready(function() {
    if (isOldIE()) return;
    
    $('#subscribe-email-submit').hover(function() {
        $(this).attr('src', '/images/ok-button-hover.png');
    }, function() {
        $(this).attr('src', '/images/ok-button.png');
    });

    var $emailInput = $('#subscribe-email');
    
    $('#subscribe-form').submit(function(e) {
        e.preventDefault();
        
        $.post('/subscribe', {email: $emailInput.val()}, function(data) {
            if (data.success) {
                $('#subscribe-email-submit').replaceWith('<img src="/images/ticked-button.png" alt="Subscribed" id="email-subscribed" />');
                $emailInput.val("").attr("placeholder", "Thank you for subscribing!")
            }
            else {
                $emailInput.val("").attr("placeholder", data.error).addClass("subscription_error")
            }
        }); 
    });
});