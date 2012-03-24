$(document).ready(function() {
    // Handle footer links
    var $moreInfoSection = $('#page-footer #more-info');
    var $moreInfo = $moreInfoSection.find('.content').wrapInner('<div class="ajax-content"></div>');
    
    $moreInfoSection.on('click', 'a', function(e) {
        if (extClick(e)) return;
        e.preventDefault();
        
        var $this = $(this);
        var $li = $this.parent('li');
        if ($li.hasClass('selected')) return;
        
        var $oldContent = $moreInfo.find('.ajax-content').fadeOut(function() {
            $oldContent.remove();
        });
        
        $.ajax({
            url: '/more_info',
            type: 'GET',
            dataType: 'html',
            data: { section: $this.data('section') },
            success: function(data) {
                $('.ajax-content', data).hide().appendTo($moreInfo).fadeIn();
                $moreInfoSection.find('.selected').removeClass('selected');
                $li.addClass('selected');
            },
            error: function(xhr) {
                $oldContent.stop().show().css('opacity', 1).appendTo($moreInfo);
                displayError(xhr);
            }
        });
    });
});