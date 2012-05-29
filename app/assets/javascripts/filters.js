$(document).ready(function() {
    if (isOldIE()) return;
    var $body = $('body');
    if (!$body.hasClass('store')) return;
    
    $('#search-submit').hover(function() {
        $(this).attr('src', '/images/search-hover.png');
    }, function() {
        $(this).attr('src', '/images/search.png');
    });

    var $products = $('#products');
    
    // Pagination links
    $products.on('click', '.pagination a', function(e) {
        if (extClick(e)) return;
        e.preventDefault();;
        
        getProducts(this.href);
    });
    
    // Sorting links
    $products.on('click', '.sort a', function(e) {
        if (extClick(e)) return;
        e.preventDefault();
        
        var $link = $(this);
        var $prev = null;
        var thisClass = $link.attr('class');
        var prevClass;
        
        if ($link.hasClass("current")) {
            if ($link.text() != "random") {
                if ($link.hasClass("asc"))
                    $link.removeClass("asc").addClass("desc");
                else
                    $link.removeClass("desc").addClass("asc");
            }
        }
        else {
            $prev = $link.closest('.sort').find('.current:first')
            prevClass = $prev.attr('class');
            $prev.removeClass('current asc desc');
            $link.addClass('current asc');
            if ($link.text == "random") $link.removeClass('asc');
        }
        
        getProducts(this.href, null, null, function() {
            $link.attr('class', thisClass);
            if ($prev) $prev.attr('class', prevClass);
        }, true)
    });
    
    // Collections
    var $collections = $('#collections').on('click', 'a', function(e) {
        if (extClick(e)) return;
        e.preventDefault();
        
        var $link = $(this);
        var $prev = $collections.find('.current:first').removeClass('current');
        $link.addClass('current');
        
        getProducts(this.href, null, null, function() {
            $link.removeClass('current');
            $prev.addClass('current');
        })
    });
    
    // Clear filters button
    $products.on('click', '.clear-link', function(e) {
        e.preventDefault();
        
        var $link = $(this);
        $link.closest('.applied-filters').fadeOut();
        getProducts(this.href)
    });
    
    // Search box
    var $searchForm = $('#search-form').submit(function(e) {
        e.preventDefault();
        
        getProducts('/?' + $(this).serialize());
    });
    
    // Filters
    $filters = $('#filters');
    $filters.find('.submit').remove();
    
    $filters.on('click', 'a', function(e) {
        if (extClick(e)) return;
        e.preventDefault();
        
        var $link = $(this);
        var $prev = $link.closest('ul').find('.current:first').removeClass('current');
        $link.addClass('current');
        
        getProducts(this.href, null, null, function() {
            $link.removeClass('current');
            $prev.addClass('current');
        })
    });
    
    // Filters - textboxes
    var typingTimer;
    var doneTypingInterval = 300;
    
    var $ageText = $filters.find('.age input[type=text]').keyup(function(){
        clearTimeout(typingTimer);
        typingTimer = setTimeout(ageChanged, doneTypingInterval);
    });
    
    function ageChanged() {
        var $ul = $ageText.closest('ul');
        var $prev = $ul.find('.current:first').removeClass('current');
        if ($ageText.val()) {
            $ageText.siblings('span').addClass('current');
        }
        else {
            $ul.find('li:first a').addClass('current');
        }
        
        getProducts('/?' + $ageText.closest('form').serialize(), null, null, function() {
            $ul.find('.current:first').removeClass('current');
            $prev.addClass('current');
        })
    }
    
    var $priceText = $filters.find('.price input[type=text]').keyup(function(){
        clearTimeout(typingTimer);
        typingTimer = setTimeout(priceChanged, doneTypingInterval);
    });
    
    function priceChanged() {
        var $ul = $priceText.closest('ul');
        var $prev = $ul.find('.current:first').removeClass('current');
        if ($priceText.val()) {
            $priceText.parent('li').find('span:first').addClass('current');
        }
        else {
            $ul.find('li:first a').addClass('current');
        }
        
        getProducts('/?' + $priceText.closest('form').serialize(), null, null, function() {
            $ul.find('.current:first').removeClass('current');
            $prev.addClass('current');
        })
    }
    
    var $searchText = $('#search');
    
    
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
            dataType: 'json',
            data: params,
            success: function(data) {
                
                html = data.html
                
                var $newCovers = $('.covers', html)
                    .removeClass()
                    .addClass("ajax-content")
                    .hide();
                
                $coversLoading.remove();
                
                $covers.append($newCovers);
                $newCovers.fadeIn();
                setTimeout(function() {
                    $covers.height($newCovers.height());
                }, 100);
                
                $products.find('.pagination,.sort,.applied-filters').remove().end()
                    .prepend($('.sort', html))
                    .prepend($('.applied-filters', html))
                    .append($('.pagination', html));
                
                updateCollections(data);
                updateFilters(data);
                
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
    
    // Add popstate after a delay, to fix the initial popstate bug
    setTimeout(function() {
        $(window).on('popstate', function(e) {
            // Restore popped state
            var data = e.originalEvent.state;
            
            if (data) {
                html = data.html
                
                var $newCovers = $('.covers', html)
                    .removeClass()
                    .addClass("ajax-content")
                    .hide();
                
                $covers.empty().append($newCovers);
                $newCovers.fadeIn();
                setTimeout(function() {
                    $covers.height($newCovers.height());
                }, 100);
                
                $products.find('.pagination,.sort,.applied-filters').remove().end()
                    .prepend($('.sort', html))
                    .prepend($('.applied-filters', html))
                    .append($('.pagination', html));
                
                updateCollections(data);
                updateFilters(data);
                    
                $products.trigger("productsRefreshed");
            }
            else {
               getProducts(location.href, null, null, true)
            }
        });
    }, 1000);
    
    function updateCollections(data) {
    
        var base_params = {}
        if (data.sort_by) base_params['sort_by'] = data.sort_by
        if (data.desc) base_params['desc'] = data.desc
        
        $collections.find('.current').removeClass('current');
        
        $collections.find('a').each(function(){
            var $link = $(this);
            var $li = $link.closest('li');
            var $ul = $li.closest('ul');
            var params = {}
            
            if ($li.hasClass('recent')) {
                params['recent'] = '1';
                if (data.base == "recent" && data.base_val) {
                    $link.addClass('current');
                }
            }
            else if ($li.hasClass('award_winning')) {
                params['award_winning'] = '1';
                if (data.base == "award_winning" && data.base_val) {
                    $link.addClass('current');
                }
            }
            else if ($li.hasClass('all') && !data.base) {
                $link.addClass('current');
            }
            else if($li.data('val')) { 
                params['collection'] = $li.data('val');
            }
            
            $.extend(params, base_params);
            
            $link.attr('href', '/?' + $.param(params) + '#products');
        });
        
        if (data.base == 'collection')
            $collections.find('li[data-val=' + data.base_val + ']').children('a').addClass('current');
        
        // Search form
        $searchForm.find('input[type=hidden]').remove();
        $.each(base_params, function(k, v) {
            $searchForm.append('<input type="hidden" name="' + k +'" value="' + v + '" />');
        });
        
        // Clear search box
        if (data.base != "search") $searchText.val('');
    }
    
    var $ageForm = $ageText.closest('form');
    var $priceForm = $priceText.closest('form');
    
    function updateFilters(data) {
        var base_params = {}
        if (data.sort_by) base_params['sort_by'] = data.sort_by;
        if (data.desc) base_params['desc'] = data.desc;
        if (data.base) base_params[data.base] = data.base_val;
        
        // Update links
        $filters.find('.current').removeClass('current');
        $filters.find('a').each(function() {
            var $link = $(this);
            var $li = $link.closest('li');
            var $ul = $li.closest('ul');
            var name = $ul.data('name');
            var val = $li.data('val');
            var params = $.extend({}, base_params, data.filters);
            
            if (data.filters[name] == val) {
                $link.addClass('current');
            }
            
            if (name == "price") {
                delete params["price_to"];
                delete params["price_from"];
            }
            
            delete params[name]
            if (val) params[name] = val
            $link.attr('href', '/?' + $.param(params) + '#products');
        });
        
        // Age form
        var age_params = $.extend({}, base_params, data.filters);
        delete age_params["age"];
        $ageForm.find('input[type=hidden]').remove();
        
        $.each(age_params, function(k,v) {
            $ageForm.append('<input type="hidden" name="' + k +'" value="' + v + '" />');
        });
        
        if (!data.filters["age"]) {
            $ageText.val('');
        }
        else {
            $ageText.siblings('span').addClass('current');
        }
        
        // Price form
        var price_params = $.extend({}, base_params, data.filters);
        delete price_params["price"];
        delete price_params["price_from"];
        delete price_params["price_to"];
        $priceForm.find('input[type=hidden]').remove();
        $.each(price_params, function(k,v) {
            $priceForm.append('<input type="hidden" name="' + k +'" value="' + v + '" />');
        });
        if (!data.filters["price_from"]) {
            $priceText.filter('#price_from').val('');
        }
        else {
            $priceForm.find('.custom span:first').addClass('current')
                .closest('ul').find('a.current').removeClass('current');
        }
        if (!data.filters["price_to"]) {
            $priceText.filter('#price_to').val('');
        }
        else {
            $priceForm.find('.custom span:first').addClass('current')
                .closest('ul').find('a.current').removeClass('current');
        }
    }
});