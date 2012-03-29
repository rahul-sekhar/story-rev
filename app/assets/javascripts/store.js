$(document).ready(function() {
    var $body = $('body');
    if (!$body.hasClass('store')) return;
    
    // Handle product information popups
    var $bookInfoDialog = $('<section id="book-info-dialog" class="dialog"></section>');
    $bookInfoDialog.dialog({
        position: "center",
        width: 600,
        height: 600,
        autoOpen:false
    });
    //$bookInfoDialog.closest('.ui-dialog').css('position', 'absolute');
    var $closeButton = $('<a href="#" class="close-button">Close</a>').click(function(e) {
        e.preventDefault();
        $bookInfoDialog.dialog('close');
    });
    var $bookInfoLoading = $('<p class="loading-large"><img alt="" src="/images/loading2.gif" /><br />Loading...</p>');
    
    $body.on('click', '.product-link', function(e) {
        
        // If an unavailable shopping cart copy was clicked on, remove it from the cart
        var $this = $(this);
        if ($this.hasClass("unavailable-copy")) {
            var copy_id = $this.closest('tr').data('id');
            $.post("/shopping_cart.json", {
                _method: "PUT",
                shopping_cart: { remove_copy: copy_id }
            }, function(data) {
                updateShoppingCartCount(data.item_count);
            });
        }
        
        if (extClick(e)) return;
        e.preventDefault();
        
        closeOtherDialogs('book-info-dialog');
        $closeButton.detach();
        
        $bookInfoDialog.empty()
            .append($closeButton)
            .append($bookInfoLoading.show())
            .dialog('open');
        
        $bookInfoLoading.css('top', $bookInfoDialog.height() / 2 - $bookInfoLoading.height() / 2 + 'px');
            
        $.ajax({
            url: this.href,
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
    
    // Handle 'add to cart' links
    $body.on('click', '.cart .buy-link', function(e) {
        if (extClick(e)) return;
        e.preventDefault();
        
        var $this = $(this)
        var copy_id = $this.closest("tr").data("id");
        var $loading = $('<span class="loading" title="Adding...">Adding</span>');
        $this.replaceWith($loading);
        
        $.ajax({
            url: "/shopping_cart.json",
            data: {
                _method: "PUT",
                shopping_cart: { add_copy: copy_id }
            },
            success: function(data) {
                var $added = $('<span class="added" title="Added to cart">In Cart</span>');
                $loading.replaceWith($added);
                $('<a href="/update_cart?shopping_cart%5Bremove_copy%5D=' + copy_id + '" class="remove-link" title="Remove from cart">Remove</a>')
                    .hide()
                    .insertAfter($added)
                    .fadeIn();
                updateShoppingCartCount(data.item_count);
                $shoppingCartLink.click();
            },
            error: function(xhr) {
                $loading.replaceWith($this);
                displayError(xhr);
            }
        });
    });
    
    // Handle 'remove from cart' links
    $body.on('click', '.cart .remove-link', function(e) {
        if (extClick(e)) return;
        e.preventDefault();
        
        var $removeLink = $(this);
        var $icon = $removeLink.prev('span');
        $removeLink.fadeOut(function() {
            $(this).remove();
        });
        var copy_id = $icon.closest("tr").data("id");
        var $loading = $('<span class="loading" title="Removing...">Removing</span>');
        $icon.replaceWith($loading);
        
        $.ajax({
            url: "/shopping_cart.json",
            data: {
                _method: "PUT",
                shopping_cart: { remove_copy: copy_id }
            },
            success: function(data) {
                var $buyLink = $('<a href="/update_cart?shopping_cart%5Badd_copy%5D=' + copy_id + '" class="buy-link" title="Add to cart">Buy</a>')
                $loading.replaceWith($buyLink);
                updateShoppingCartCount(data.item_count);
            },
            error: function(xhr){
                $loading.replaceWith($icon);
                $removeLink.stop().show().css('opacity', 1).insertAfter($icon);
                displayError(xhr);
            }
        });
    });
    
    /* ------------------- Order dialog ---------------------------*/
    
    var $orderLoading = $bookInfoLoading.clone();
    var $orderDialog = $('<section id="order-dialog" class="dialog"></section>');
    $orderDialog.dialog({
        position: "center",
        width: 600,
        height: 400,
        autoOpen:false
    });
    
    var $orderCloseButton = $('<a href="#" class="close-button">Close</a>').click(function(e) {
        e.preventDefault();
        
        $orderDialog.dialog("close");
    });
    
    $body.on('click', '.order-button', function(e) {
        if (extClick(e)) return;
        e.preventDefault();
        
        if ($shoppingCartSection.find('.unavailable').length > 0) {
            var message = "Some copies in your shopping cart are now unavailable. These copies will not be included in the order.";
            displayNotice(message, "Continue", openOrderDialog)
        }
        else {
            openOrderDialog();
        }
    });
    
    function openOrderDialog() {
        closeOtherDialogs('order-dialog');
        
        $orderCloseButton.detach();
        $orderDialog.empty()
            .append($orderCloseButton)
            .append($orderLoading.css('opacity',1).show())
            .dialog('open');
        
        $shoppingCartDialog.dialog("option", "position", "center")
        
        $orderLoading.css('top', $orderDialog.height() / 2 - $orderLoading.height() / 2 + 'px');
        
        $.ajax({
            url: '/order',
            type: 'GET',
            dataType: 'html',
            data: {ajax: true},
            success: function(data) {
                var $order = $('#order', data);
                $orderLoading.remove();
                $orderDialog.append($order.hide());
                
                $orderSection = $order;
                $order.fadeIn();
                
                setTimeout(function() {
                    resizeDialog($orderDialog, $order, true, true, function() {
                        $orderDialog.css('height', 'auto');
                    });
                }, 50);
            },
            error: function(xhr) {
                $orderDialog.dialog("close");
                displayError(xhr);
            }
        });
    }
    
    var $orderSection = $('#order');
    
    // Handle next, previous and cancel buttons
    $orderDialog.add($orderSection).on('submit', 'form', function(e) {
        var $form = $(this);
        if ($form.is('#cancel-order') && !$form.closest('.ui-dialog').length) return;
        e.preventDefault();
        
        if ($form.is('#cancel-order')) {
            $orderDialog.dialog("close");
            
            $.ajax({
                url: '/order',
                data: {_method: 'DELETE', ajax: true},
                error: function(xhr) {
                    displayError(xhr);
                }
            });
            return;
        }
        
        var $removedHtml = dialogShowLoading($orderSection, $orderLoading, 'Order');
        
        $.ajax({
            url: '/order',
            dataType: 'html',
            data: $.extend({}, $form.serializeObject(), {ajax: true}),
            success: function(data) {
                dialogSwitchHtml($orderSection, $orderLoading, $('#order', data));
            },
            error: function(xhr) {
                $orderSection.empty().append($removedHtml.contents());
                displayError(xhr);
            }
        });
    })
    
    // Refresh the shopping cart count when the order dialog is closed
    $orderDialog.on("dialogclose", function() {
        $.get('/shopping_cart', { count: true }, function(data) {
            updateShoppingCartCount(data.item_count);
        });
    });
    
    /* ------------------- Shopping cart dialog ---------------------------*/
    
    var $shoppingCartLoading = $bookInfoLoading.clone();
    var $shoppingCartLink = $('#shopping-cart-link');
    var $shoppingCartDialog = $('<section id="shopping-cart-dialog" class="dialog"></section>');
    $shoppingCartDialog.dialog({
        position: "center",
        width: 540,
        height: 400,
        autoOpen:false
    });
    
    var $cartCloseButton = $('<a href="#" class="close-button">Close</a>').click(function(e) {
        e.preventDefault();
        $shoppingCartDialog.dialog('close');
    });
    
    $shoppingCartLink.on('click', function(e) {
        if (extClick(e)) return;
        e.preventDefault();
        
        closeOtherDialogs('shopping-cart-dialog');
        
        $cartCloseButton.detach();
        $shoppingCartDialog.empty()
            .append($cartCloseButton)
            .append($shoppingCartLoading.css('opacity',1).show())
            .dialog('open');
        
        $shoppingCartLoading.css('top', $shoppingCartDialog.height() / 2 - $shoppingCartLoading.height() / 2 + 'px');
        
        $.ajax({
            url: '/shopping_cart',
            type: 'GET',
            dataType: 'html',
            data: {ajax: true},
            success: function(data) {
                var $shoppingCart = $('#shopping-cart', data).find('.back-button').remove().end();
                $shoppingCartLoading.remove();
                $shoppingCartDialog.append($shoppingCart.hide());
                
                $shoppingCartSection = $shoppingCart;
                updateShoppingCartCount($shoppingCart.find('.container').data('count'));
                
                $shoppingCart.fadeIn();
                
                setTimeout(function() {
                    resizeDialog($shoppingCartDialog, $shoppingCart, true, true, function() {
                        $shoppingCartDialog.css('height', 'auto');
                    });
                }, 50);
            },
            error: function(xhr) {
                $shoppingCartDialog.dialog("close");
                displayError(xhr);
            }
        });
    });
    
    // Handle emptying the cart
    var $shoppingCartSection = $('#shopping-cart');
    var $shoppingCartSectionDialog = $shoppingCartSection.add($shoppingCartDialog);
    $shoppingCartSectionDialog.on('click', '#empty-button', function(e) {
        handleShoppingCartButton(e, { empty: true });
    });
    
    // Handle 'remove from cart' links
    $shoppingCartSectionDialog.on('click', '.remove-link', function(e) {
        var copy_id = $(this).closest("tr").data("id");
        handleShoppingCartButton(e, { remove_copy: copy_id });
    });
    
    // Generic function to handle each of the shopping cart buttons
    function handleShoppingCartButton(e, params, successFunction) {
        if (extClick(e)) return;
        e.preventDefault();
        
        var $removedHtml = dialogShowLoading($shoppingCartSection, $shoppingCartLoading, 'Shopping Cart');
        
        $.ajax({
            url: '/shopping_cart.json',
            data: {
                _method: "PUT",
                shopping_cart: params,
                get_html: true
            },
            success: function(data) {
                dialogSwitchHtml($shoppingCartSection, $shoppingCartLoading, $('#shopping-cart', data.html));
                updateShoppingCartCount(data.item_count);
                
                if (successFunction) successFunction();
            },
            error: function(xhr) {
                $shoppingCartSection.empty().append($removedHtml.contents());
                displayError(xhr);
            }
        });
    }
    
    // Function to update the shopping cart item count
    function updateShoppingCartCount(count) {
        $shoppingCartLink.text('Shopping Cart (' + count + ')');
    }
    
    // To refresh a dialogs HTML
    function dialogShowLoading($section, $loading, heading) {
        var section_height = $section.height();
        
        $section.height(section_height)
            .wrapInner('<div class="js-remove"></div>')
            .append('<h2>' + heading + '</h2>');
        
        var $jsRemove = $section.find('.js-remove')
            .height(section_height)
            .width($section.width())
            .fadeOut(function() {
                $jsRemove.remove();
            });
        
        $loading.hide()
            .appendTo($section)
            .fadeIn();
        
        // Return the removed block of data
        return $jsRemove;
    }
        
    function dialogSwitchHtml($section, $loading, $newSection) {
        $newSection.attr('id', null)
            .removeClass()
            .addClass('ajax-content')
            .hide();
        
        if ($section.closest('.ui-dialog').length > 0)
            $newSection.find('.back-button').remove();
        
        $newSection.find('h2').remove();
        $loading.remove();
        
        $section.append($newSection);
        $newSection.fadeIn();
        setTimeout(function() {
            resizeDialog($section, $newSection);
        }, 50);
    }
    
    // Resize a dialog to its contents height by sliding (check again after resizing)
    function resizeDialog($dialog, $content, resize_overlay, center_dialog, callbackFunction) {
    
        if ($dialog.height() != $content.outerHeight()) {
            
            if (center_dialog) {
                var page_top = $(window).scrollTop();
                var target_top =  page_top + $(window).height() / 2 - $content.outerHeight() / 2 - ($dialog.outerHeight() - $dialog.height()) / 2;
                
                if (target_top < (page_top + 10)) target_top = page_top + 10
                
                $dialog.closest('.ui-dialog').animate({top: target_top + 'px'}, 500);
            }
            
            $dialog.animate({ height: $content.outerHeight() }, 500, function() {
                if (resize_overlay)
                    resizeOverlay();
                
                resizeDialog($dialog, $content, resize_overlay, center_dialog, callbackFunction);
            });
        }
        else {
            if (callbackFunction) {
                callbackFunction();
            }
        }
    }
});