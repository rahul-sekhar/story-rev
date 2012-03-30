$(document).ready(function() {
    var $body = $('body');
    if (!$body.hasClass('orders')) return;
    
    var $ordersTable = $('#orders-table');
    $ordersTable.itemTable({
        selectable: true,
        removable: false,
        editable: false,
        addable: false
    });
    
    $ordersTable.on('click', 'input', function(e) {
        e.preventDefault();
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
        })
    });
    
    var $orderInfo = $('#order-info');
    
    $ordersTable.on("selectionChange", function(e, id) {
        $orderInfo.hide();
        $.get('/admin/orders/' + id, function(data) {
            console.log(data);
            $orderInfo.find(".name").text(data.name);
            $orderInfo.find(".email").text(data.email);
            $orderInfo.find(".address").text(data.address);
            $orderInfo.find(".phone").text(data.phone);
            $orderInfo.show();
        });
    });
});