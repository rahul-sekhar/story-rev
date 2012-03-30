$(document).ready(function() {
    var $body = $('body');
    if (!$body.hasClass('orders')) return;
    
    var $ordersTable = $('#orders-table');
    $ordersTable.itemTable({
        url: '/admin/orders',
        selectable: true,
        editable: false,
        addable: false,
        columns: [
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
                        number: number
                    }
                },
                success: function(data) {
                    $number.text(number);
                    $this.show();
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
    });
    
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
    
    $orderInfo.find('.comments .edit-link').click(function() {
        var $this = $(this);
        var $pre = $this.siblings('pre');
        var $textbox = $('<textarea></textarea>').text($pre.text());
        
        var saveEdit = function() {
            var text = $textbox.val();
            console.log(text);
            $.ajax ({
                url: '/admin/orders/' + curr_id,
                method: 'POST',
                data: {
                    _method: 'PUT',
                    order: {
                        other_info: text
                    }
                },
                success: function(data) {
                    $textbox.replaceWith($pre.text(text));
                    $this.show();
                },
                error: function(data) {
                    $textbox.replaceWith($pre);
                    $this.show();
                }
            })
        }
        
        $textbox.blur(saveEdit);
        $pre.replaceWith($textbox);
        $this.hide();
        $textbox.focus();
    });
});