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
            clearFilters();
        }, function() {
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
            clearFilters();
        }, function() {
            $link.removeClass('current');
            $prev.addClass('current');
        })
    });
    
    var filterCache;
    
    // Filters
    var $filters = $('#filters');
    var $filterForm = $filters.find('form:first');
    
    function filtersChanged() {
        var data = $filterForm.serializeObject();
        var params = $filterForm.serialize();
        if (filterCache == params) return;
        
        filterCache = params;
        getProducts($collections.find('.current:first').attr('href'), data, null, null, true);
    }
    
    $filters.find('.submit-container, .params').remove();
    $filters.on('change', 'input[type=checkbox]', filtersChanged);
    
    // Filters - textboxes
    var typingTimer;
    var doneTypingInterval = 300;
    
    $filters.find('input[type=text]').keyup(function(){
        clearTimeout(typingTimer);
        typingTimer = setTimeout(filtersChanged, doneTypingInterval);
    });
    
    //Function to clear all the filters
    function clearFilters() {
        $filters.find('input[type=text]').val('');
        $filters.find('input[type=checkbox]').prop('checked', false);
        filterCache = null
    }
    
    
    // Function to get the current sorted state
    function getSort() {
        return $products.find('.sort').data('current');
    }
    
    // Function to get the current collection id
    function getCollectionId() {
        return $products.find('.sort').data('collection');
    }
    
    
    // Function to handle getting filtered data and replacing the product list
    var $covers = $products.find('.covers');
    var $coversLoading = $('<p class="loading-large"><img alt="" src="/images/loading2.gif" /><br />Loading...</p>');
    var prev_xhr;
    
    function getProducts(url, data, success, error, no_pushstate) {
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
        
        var params = {ajax: true};
        if (data)
            $.extend(params, data);
        
        var xhr = $.ajax({
            url: url,
            type: 'GET',
            dataType: 'html',
            data: params,
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
                }, 100);
                
                $products.find('.pagination,.sort').remove().end()
                    .prepend($('.sort', data))
                    .append($('.pagination', data));
                
                // Update collection URL with the new sort by parameter
                if (getSort()) {
                    $collections.find('a').each(function() {
                        this.href = this.href.replace(/sort=\w*/, "sort=" + getSort());
                    });
                }
                
                // Select the correct collection item
                $collections.find('.current').removeClass('current');
                $collections.find('#' + getCollectionId() + ' a').addClass('current');
                
                if (!no_pushstate && Modernizr.history) {
                    // Add url to the browser history
                    history.pushState(data, null, url);
                }
                
                // Trigger an event so product hover info is refreshed
                $products.trigger("productsRefreshed");
                
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
        
        // Restore popped state
        var data = e.originalEvent.state;
        
        if (data) {
            var $newCovers = $('.covers', data)
                .removeClass()
                .addClass("ajax-content")
                .hide();
            
            $covers.empty().append($newCovers);
            $newCovers.fadeIn();
            setTimeout(function() {
                $covers.height($newCovers.height());
            }, 100);
            
            $products.find('.pagination,.sort').remove().end()
                .prepend($('.sort', data))
                .append($('.pagination', data));
            
            console.log(getCollectionId())
            // Select the correct collection item
            $collections.find('.current').removeClass('current').hide().show();
            $collections.find('#' + getCollectionId() + ' a').addClass('current').hide().show();
            
            clearFilters();
            
            // Update collection URL with the new sort by parameter
            if (getSort()) {
                $collections.find('a').each(function() {
                    this.href = this.href.replace(/sort=\w*/, "sort=" + getSort());
                });
            }
            
            $products.trigger("productsRefreshed");
        }
        else {
           getProducts(location.href, null, function() {
                clearFilters();
            }, null, true)
        }
    });
});