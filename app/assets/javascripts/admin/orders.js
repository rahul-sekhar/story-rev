$(document).ready(function() {
    var $body = $('body');
    if (!$body.hasClass('orders')) return;
    
    // Table settings for the list of orders
    var $ordersTable = $('#orders-table');
    $ordersTable.itemTable({
        url: '/admin/orders',
        selectable: true,
        editable: false,
        addable: false,
        columns: [
            {
                name: 'Order ID'
            },
            {
                name: 'Name'
            },
            {
                name: 'City'
            },
            {
                name: 'Delivery Method'
            },
            {
                name: 'Number of copies'
            },
            {
                name: 'Total amount'
            }
        ]
    });
    
    // Handle checkboxes on the order list
    $ordersTable.on('click', 'input', function(e) {
        var $this = $(this);
        $this.prop('disabled', true);
        var order_id = $this.closest('tr').data('id');
        var val = ($this.is(':checked'));
        var params = {};
        params[$this.attr('class')] = val;
        
        $.ajax({
            url: '/admin/orders/' + order_id,
            method: 'POST',
            data: {
                _method: 'PUT',
                order: params
            },
            success: function(data) {
                $this.prop('checked', val)
                $this.prop('disabled', false);
            },
            error: function(data) {
                $this.prop('disabled', false);
            }
        });
    });
    
    // Handle checkboxes in the copies list for each order
    var curr_id;
    var $orderInfo = $('#order-info');
    var $copiesTable = $orderInfo.find('table').on('click', '.ticked', function(e) {
        var $this = $(this);
        $this.prop('disabled', true);
        var order_copy_id = $this.closest('tr').data('id');
        var val = ($this.is(':checked'));
        
        $.ajax({
            url: '/admin/orders/' + curr_id + '/order_copies/' + order_copy_id,
            method: 'POST',
            data: {
                _method: 'PUT',
                order_copy: {
                    ticked: val
                }
            },
            success: function(data) {
                $this.prop('checked', val)
                $this.prop('disabled', false);
            },
            error: function(data) {
                $this.prop('disabled', false);
            }
        });
    // And handle editing each copy
    }).on('click', '.edit-link', function(e) {
        e.preventDefault();
        
        var $this = $(this);
        var $tr = $this.closest("tr");
        var order_copy_id = $tr.data("id");
        var $number = $tr.find(".copy-number");
        var old_number = parseInt($number.text(), 10);
        
        var saveNumber = function() {
            var number = parseInt($textbox.val(), 10);
            if (!number || number < 0) number = 1;
            $textbox.remove();
            
            $.ajax({
                url: '/admin/orders/' + curr_id + '/order_copies/' + order_copy_id,
                data: {
                    _method: "PUT",
                    order_copy: {
                        set_number: number
                    }
                },
                success: function(data) {
                    $number.text(number);
                    $this.show();
                    
                    updateOrderAmount(data);
                },
                error: function(data) {
                    $number.text(old_number);
                    $this.show();
                }
            });
        };
        
        var $textbox = $('<input type="text" name="number" value="' + old_number + '" />')
            .on('blur', saveNumber);
        
        $number.empty().append($textbox);
        $textbox.focus();
        $this.hide();
    }).on('itemRemove', function(e, data) {
        updateOrderAmount(data);
    });
    
    // Handle changing the order information when an order is selected from the list
    $ordersTable.on("selectionChange", function(e, id) {
        $orderInfo.hide();
        curr_id = id;
        if (!curr_id) return;
        
        // Update the order info
        $.get('/admin/orders/' + id, function(data) {
            $orderInfo.find(".name").text(data.name).end()
                .find(".email").text(data.email).end()
                .find(".address pre").text(data.address || "").end()
                .find(".phone").text(data.phone).end()
                .find(".comments pre").text(data.other_info).end()
                .find(".payment").text(data.payment_text).end()
                .find(".delivery").text(data.delivery_text).end()
                .find(".pickup").text(data.pickup_point_text).end()
                .find(".total span").text(data.total_amount).end()
                .find(".postage span").text(data.postage_amount).end()
                .find(".postage-expenditure")
                    .data("value", data.postage_expenditure_val)
                    .find("span").text(data.postage_expenditure).end()
                    .end()
                .find(".notes pre").text(data.notes).end()
                .show();
                
                // Update the copies table
                $copiesTable.itemTable({
                    url: '/admin/orders/' + id + '/order_copies',
                    objectName: 'order_copy',
                    addable: false,
                    editable: false,
                    initialLoad: true,
                    numbered: true,
                    columns: [
                        {
                            name: 'Title',
                            field: 'title'
                        },
                        {
                            name: 'Author',
                            field: 'author_name'
                        },
                        {
                            name: 'Accession Number',
                            field: 'accession_id',
                            class_name: 'accession_id'
                        },
                        {
                            name: 'Price',
                            field: 'price'
                        },
                        {
                            name: 'Number',
                            field: 'number',
                            class_name: 'copy-number'
                        },
                        {
                            name: 'Edit Number',
                            field: 'new_copy',
                            class_name: 'has-button edit-number',
                            displayCallback: function(data) {
                                return data ? '<a class="edit-link" href="#"></a>' : ''
                            },
                            type: 'html'
                        },
                        {
                            name: 'Format',
                            field: 'format_name'
                        },
                        {
                            name: 'ISBN',
                            field: 'isbn'
                        },
                        {
                            name: 'Rating',
                            field: 'condition_rating',
                            type: 'rating',
                            class_name: 'rating'
                        },
                        {
                            name: 'Ticked',
                            field: 'ticked',
                            class_name: 'has-button',
                            type: 'html',
                            displayCallback: function(data) {
                                return '<input class="ticked" type="checkbox" ' + (data ? 'checked="checked" ' : '') + '/>';
                            }
                        }
                    ]
                });
        });
    });
    
    // Handle editing postage expenditure
    $orderInfo.find('.postage-expenditure .edit-link').click(function(e) {
        e.preventDefault();
        
        var $this = $(this);
        var $container = $this.parent();
        var $span = $this.siblings('span');
        var $textbox = $('<input type="text" />').val($container.data("value"));
        
        var saveEdit = function() {
            var val = $textbox.val();
            
            $.ajax ({
                url: '/admin/orders/' + curr_id,
                method: 'POST',
                data: {
                    _method: 'PUT',
                    order: {
                        postage_expenditure: val
                    }
                },
                success: function(data) {
                    $textbox.replaceWith($span.text(data.postage_expenditure));
                    $container.data("value", data.postage_expenditure_val);
                    $this.show();
                },
                error: function(data) {
                    $textbox.replaceWith($span);
                    $this.show();
                }
            })
        }
        
        $textbox.blur(saveEdit);
        $span.replaceWith($textbox);
        $this.hide();
        $textbox.focus();
    });
    
    // Handle editing order comments
    $orderInfo.find('.comments .edit-link, .notes .edit-link').click(function(e) {
        e.preventDefault();
        
        var $this = $(this);
        var $container = $this.parent();
        var $pre = $this.siblings('pre');
        var $textbox = $('<textarea></textarea>').text($pre.text());
        var param_name;
        param_name = ($container.hasClass("comments")) ? "other_info" : "notes";
        
        var saveEdit = function() {
            var text = $textbox.val();
            var order_params = {};
            order_params[param_name] = text;
            
            $.ajax ({
                url: '/admin/orders/' + curr_id,
                method: 'POST',
                data: {
                    _method: 'PUT',
                    order: order_params
                },
                success: function(data) {
                    $textbox.replaceWith($pre.text(text));
                    $container.height("auto");
                    $this.show();
                },
                error: function(data) {
                    $textbox.replaceWith($pre);
                    $this.show();
                }
            })
        }
        
        $textbox.blur(saveEdit);
        $container.height($container.height());
        $pre.replaceWith($textbox);
        $this.hide();
        $textbox.focus();
    });
    
    // Handle manually adding books to orders
    var $addDialog = $('<section id="add-order-copy" class="dialog"></section');
    $('<a class="close-button" href="#"></a>').click(function(e) {
        e.preventDefault();
        $.unblockUI();
    }).appendTo($addDialog);
    
    var book_id = null
    
    var $searchBox = $('<input name="book-search" class="book-search" />')
        .appendTo($addDialog)
        .tokenInput("/admin/books/search", {
            overlayHintText: 'Search by title, author, ISBN or accession number',
            tokenLimit: 1,
            addClass: "fill dialog",
            additionalParams: { search_by: "all", output: "display_target" },
            allowCustom: true,
            addFormatter: function(query) { return "<li>Add a new book - <strong>" + escapeHTML(query) + "</strong></li>" },
            onAdd: function(item) {
                book_id = item.id;
                $infoLink.data('id', book_id).show();
                $editionBox.show();
                $editionTable.itemTable({
                    url: '/admin/books/' + item.id + '/editions',
                    objectName: 'edition',
                    editable: false,
                    removable: false,
                    addable: false,
                    selectable: true,
                    initialLoad: true,
                    columns: [
                        {
                            name: 'ISBN',
                            field: 'isbn'
                        },
                        {
                            name: 'Format',
                            field: 'format_name',
                        },
                        {
                            name: 'Publisher',
                            field: 'publisher_name',
                        }
                    ]
                })
            },
            onDelete: function(){
                book_id = null;
                $infoLink.hide();
                $editionBox.hide();
                $copyBox.hide();
            }
        });
    
    var $infoLink = $('<a href="#" class="zoom-link"></a>').appendTo($addDialog).hide();
    
    var $editionBox = $('<div class="editions"></div>').appendTo($addDialog).hide();
    $editionBox.append('<p>Editions</p>')
        .append('<div class="table-container editions"><table></table></div>');
    var $editionTable = $editionBox.find('table');
    
    var $copyBox = $('<div class="copies"></div>').appendTo($addDialog).hide();
    $copyBox.append('<p>Copies</p>')
        .append('<div class="table-container copies"><table></table></div>');
    var $copyTable = $copyBox.find('table');
    
    $editionTable.on("selectionChange", function(e, id) {
        $copyBox.show();
        
        $copyTable.itemTable({
            url: '/admin/books/' + book_id + '/editions/' + id + '/copies',
            objectName: 'copy',
            editable: false,
            removable: false,
            addable: false,
            initialLoad: true,
            columns: [
                {
                    name: 'Accession Number',
                    field: 'accession_id',
                    type: 'read_only',
                    class_name: 'accession_id'
                },
                {
                    name: 'Condition',
                    field: 'condition_rating',
                    multilineLabel: true,
                    type: 'rating'
                },
                {
                    name: 'Condition Description',
                    multilineLabel: true,
                    field: 'condition_description'
                },
                {
                    name: 'Price',
                    field: 'formatted_price',
                    raw: 'price'
                },
                {
                    name: 'Number',
                    field: 'number',
                },
                {
                    name: 'Add to order',
                    type: 'fixed',
                    class_name: 'has-button',
                    html_content: '<a class="add-link" href="#"></a>'
                }
            ]
        });
    });
    
    $copyTable.on('click', '.add-link', function(e) {
        e.preventDefault();
        
        var copy_id = $(this).closest('tr').data('id');
        
        $.ajax({
            url: '/admin/orders/' + curr_id,
            method: 'POST',
            data: {
                _method: 'PUT',
                order: {
                    add_copy: copy_id
                }
            },
            success: function(data) {
                updateOrderAmount(data);
                $ordersTable.trigger("selectionChange", curr_id);
            },
            error: function(data) {
                $ordersTable.trigger("selectionChange", curr_id);
            }
        });
        
        $.unblockUI();
    })
    
    $orderInfo.on('click', '.add-link', function(e) {
        e.preventDefault();
        
        $searchBox.tokenInput("reset");
        
        $.blockUI({
            message: $addDialog,
            css: { 
                width:          '40%', 
                top:            '10%', 
                left:           '30%', 
                textAlign:      'left', 
                backgroundColor:'#fff', 
                padding:        '20px'
            }
        });
    });
    
    // Handle initial selection for the orders table
    var initId = $ordersTable.data('init-select');
    if (initId) {
        $ordersTable.find('tr.selected').removeClass('selected');
        var $selectedRow = $ordersTable.find('tr[data-id=' + initId + ']').addClass('selected');
        $ordersTable.parent().scrollTop($selectedRow.position().top);
        $ordersTable.trigger("selectionChange", initId);
    }
    
    function updateOrderAmount(data) {
        $orderInfo.find('.total span').text(data.total_amount)
        $orderInfo.find('.postage span').text(data.postage_amount)
        $ordersTable.find('tr[data-id=' + curr_id + '] .total').text(data.total_amount)
    }
});