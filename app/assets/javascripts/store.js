$(document).ready(function() {
    var $body = $('body');
    
    if (!$body.hasClass('store')) return;
    
    var $dialog = $('<section id="book-info-popup"></section>');
    $dialog.dialog({
        position: ['center', 20],
        width: 600,
        height: 320,
        autoOpen:false
    });
    var $closeButton = $('<a href="#" class="close-button">Close</a>').click(function(e) {
        e.preventDefault();
        $dialog.dialog('close');
    });
    var $loading = $('<img class="loading" src="images/loading2.gif" alt="Loading..." /><p class="loading">Loading...</p>');
    
    
    $('#products').on('click', 'a', function(e) {
        if (e.ctrlKey || e.metaKey) return;
        e.preventDefault();
        $closeButton.detach();
        
        $dialog.empty()
            .append($closeButton)
            .append($loading.show())
            .dialog('open');
            
        $.get(this.href, {ajax: true}, function(data) {
            var $bookInfo = $('#book-info', data);
            $loading.fadeOut().remove();
            $dialog.append($bookInfo.hide());
            $bookInfo.fadeIn();
            setTimeout(function() {
                $dialog.animate({ height: $bookInfo.outerHeight()}, 500, function() {
                    resizeOverlay();
                });
            }, 50);
        });
    });
    
    function resizeOverlay() {
        $('.ui-widget-overlay').width($(document).width())
            .height($(document).height());
    }   
});