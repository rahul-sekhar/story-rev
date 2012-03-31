$(document).ready(function() {
    var $body = $('body');
    if (!$body.hasClass('store')) return;
    
    var $products = $('#products');
    
    // Pagination links
    $products.on('click', '.pagination a', function(e) {
        if (extClick(e)) return;
        e.preventDefault();
        
        var $link = $(this);
        var $prev = $link.closest('.pagination').find('.current:first').removeClass('current');
        $link.addClass('current');
        
        getProducts(this.href, null, function() {
            $link.removeClass('current');
            $prev.addClass('current');
        })
    });
    
    // Sorting links
    $products.on('click', '.sort a', function(e) {
        if (extClick(e)) return;
        e.preventDefault();
        
        var $link = $(this);
        var $prev = $link.closest('.sort').find('.current:first').removeClass('current');
        $link.addClass('current');
        
        getProducts(this.href, null, function() {
            $link.removeClass('current');
            $prev.addClass('current');
        })
    });
    
    // Collections
    var $collections = $('#collections').on('click', 'a', function(e) {
        if (extClick(e)) return;
        e.preventDefault();
        
        var $link = $(this);
        var $prev = $collections.find('.current:first').removeClass('current');
        $link.addClass('current');
        
        getProducts(this.href, null, function() {
            $link.removeClass('current');
            $prev.addClass('current');
        })
    });
    
    
    // Function to get the current sorted state
    function getSort() {
        return $products.find('.sort').data('current');
    }
    
    
    // Function to handle getting filtered data and replacing the product list
    var $covers = $products.find('.covers');
    var $coversLoading = $('<p class="loading-large"><img alt="" src="/images/loading2.gif" /><br />Loading...</p>');
    var prev_xhr;
    
    function getProducts(url, success, error, no_pushstate) {
        // Cancel any pending requests
        if (prev_xhr) prev_xhr.abort();
        
        var cover_height = $covers.height();
        
        $covers.height(cover_height)
            .wrapInner('<div class="js-remove"></div>');
        
        var $jsRemove = $covers.find('.js-remove')
            .height(cover_height)
            .width($covers.width())
            .fadeOut(function() {
                $jsRemove.remove();
            });
        
        $coversLoading.hide()
            .appendTo($covers)
            .fadeIn();
        
        var xhr = $.ajax({
            url: url,
            type: 'GET',
            dataType: 'html',
            data: {ajax: true},
            success: function(data) {
                var $newCovers = $('.covers', data)
                    .removeClass()
                    .addClass("ajax-content")
                    .hide();
                
                $coversLoading.remove();
                
                $covers.append($newCovers);
                $newCovers.fadeIn();
                setTimeout(function() {
                    $covers.height($newCovers.height());
                }, 50);
                
                $products.find('.pagination,.sort').remove().end()
                    .prepend($('.sort', data))
                    .append($('.pagination', data));
                
                // Update collection URL with the new sort by parameter
                if (getSort()) {
                    $collections.find('a').fragment({sort: getSort()});
                }
                
                if (!no_pushstate) {
                    // Add url to the browser history
                    history.pushState(null, null, url);
                }
                
                if (success) success();
            },
            error: function(xhr) {
                if (xhr.statusText == "abort") return;
                
                $covers.empty().append($jsRemove.contents());
                
                if (error) error();
            }
        });
        
        prev_xhr = xhr
        
        xhr.always(function() {
            if (prev_xhr == xhr) {
                prev_xhr = null;
            }
        });
    }
    
    var popped = ('state' in window.history), initialURL = location.href
    $(window).on('popstate', function(e) {
        // Ignore inital popstate that some browsers fire on page load
        var initialPop = !popped && location.href == initialURL
        popped = true
        if ( initialPop ) return
        
        getProducts(location.href, null, null, true)
    });
});