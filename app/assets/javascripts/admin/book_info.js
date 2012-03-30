$(document).ready(function() {
    
    // Handle product information popups
    var $bookInfoDialog = $('<section id="book-info-dialog" class="dialog"></section>');
    $bookInfoDialog.dialog({
        position: "center",
        width: 600,
        height: 600,
        autoOpen:false
    });
    
    var $closeButton = $('<a href="#" class="close-button">Close</a>').click(function(e) {
        e.preventDefault();
        $bookInfoDialog.dialog('close');
    });
    var $bookInfoLoading = $('<p class="loading-large"><img alt="" src="/images/loading2.gif" /><br />Loading...</p>');
    
    $('body').on('click', '.zoom-link', function(e) {
        e.preventDefault();
        var url = '/products/' + $(this).data('id') || $(this).closest('tr').data('id');
        
        if (extClick(e)) {
            window.open(url);
            return;
        }
        
        $closeButton.detach();
        $bookInfoDialog.empty()
            .append($closeButton)
            .append($bookInfoLoading.show())
            .dialog('open');
        
        $bookInfoDialog.closest('.ui-dialog').css('z-index', 1502);
        $('.ui-widget-overlay').css('z-index', 1500);
        
        $bookInfoLoading.css('top', $bookInfoDialog.height() / 2 - $bookInfoLoading.height() / 2 + 'px');
        
        $.ajax({
            url: url,
            type: 'GET',
            dataType: 'html',
            data: {ajax: true},
            success: function(data) {
                var $bookInfo = $('#book-info', data).find('.back-button').remove().end();
                
                $bookInfoLoading.remove();
                $bookInfoDialog.append($bookInfo.hide());
                
                $bookInfo.fadeIn();
                setTimeout(function() {
                    resizeDialog($bookInfoDialog, $bookInfo, true, true);
                }, 50);
            },
            error: function (xhr){
                $bookInfoDialog.dialog("close");
                displayError(xhr);
            }
        });
    });
});