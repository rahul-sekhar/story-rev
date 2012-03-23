$(document).ready(function() {
    // Handle footer links
    var $moreInfoSection = $('#page-footer #more-info');
    var $moreInfo = $moreInfoSection.find('.content').wrapInner('<div class="ajax-content"></div>');
    
    $moreInfoSection.on('click', 'a', function(e) {
        e.preventDefault();
        
        var $this = $(this);
        var $li = $this.parent('li');
        if ($li.hasClass('selected')) return;
        
        $moreInfo.find('.ajax-content').fadeOut(function() {
            $(this).remove();
        });
        
        $moreInfoSection.find('.selected').removeClass('selected');
        
        $.get('/more_info', { section: $this.data('section') }, function(data) {
            $('.ajax-content', data).hide().appendTo($moreInfo).fadeIn();
            $li.addClass('selected');
        });
    });
});