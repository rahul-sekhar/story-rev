$(document).ready(function() {
    var $body = $('body');
    if (!$body.hasClass('finances')) return;
    
    // Table settings for the list of transactions
    var $transactionsTable = $('#transactions-table');
    $transactionsTable.on("addedManageLinks", function() {
        $transactionsTable.find('tr:not(.headings)[data-order-url]')
            .find('.remove-link').remove().end()
            .find('.edit-link').removeClass('edit-link').addClass('edit-order-link').attr('title', 'Edit Order');
    }).on("click", ".edit-order-link", function(e) {
        e.preventDefault();
        window.location = $(this).closest('tr').data('order-url');
    }).itemTable({
        url: '/admin/transactions',
        objectName: 'transaction',
        selectable: true,
        headings: true,
        sortable: true,
        addLinkText: 'New Transaction',
        columns: [
            {
                name: 'Date',
                raw: 'short_date',
                field: 'formatted_date',
                type:'date',
                default_val:'now',
                sort_by: 'timestamp',
                default_sort: 'desc',
                class_name: 'date'
            },
            {
                name: 'Category',
                field: 'transaction_category_name',
                raw: 'transaction_category_id',
                sort_by: 'transaction_category_name',
                type: 'dropdown',
                sourceURL: '/admin/transaction_categories'
            },
            {
                name: 'Other Party',
                field: 'other_party',
                sort_by: 'other_party'
            },
            {
                name: 'Payment method',
                field: 'payment_method_name',
                raw: 'payment_method_id',
                type:'dropdown',
                sourceURL: '/admin/payment_methods',
                sort_by: 'payment_method_name'
            },
            {
                name: 'Account',
                field: 'account_name',
                raw: 'account_id',
                type: 'dropdown',
                sourceURL: '/admin/accounts',
                sort_by: 'other_party',
            },
            {
                name: 'Notes',
                field: 'notes'
            },
            {
                name: 'Credit',
                field: 'formatted_credit',
                raw: 'credit',
                sort_by: 'credit',
                class_name: 'amount'
            },
            {
                name: 'Debit',
                field: 'formatted_debit',
                raw: 'debit',
                sort_by: 'debit',
                class_name: 'amount'
            }
        ]
    });
});

google.load('visualization', '1', {'packages':['corechart']});
google.setOnLoadCallback(function() {
    initGraph();
});

function initGraph() {
    $(document).ready(function() {
        var $graph = $('#graph');
        var chart = new google.visualization.LineChart($graph[0]);
        var options = {
            width: $graph.width(),
            height: $graph.height(),
            colors: ['#B9603E'],
            pointSize: 4,
            titlePostition:'none',
            legend: {'position': 'none'},
            vAxis: {
                gridlines: {
                    color:'#E6E6E6'
                }
            },
            chartArea: {
                left:'10%',
                top:'10%',
                width:"80%",
                height:"70%"
            }
        };
        var graph_type = "sales";
        var graph_period = "weekly";
        
        function redrawGraph() {
            $.ajaxCall('/admin/transactions/sales_data', {
                purr: false,
                data: {
                    format: graph_period,
                    data_type: graph_type
                },
                success: function(data) {
                    var graph_data = new google.visualization.DataTable();
                    graph_data.addColumn('date', 'Date');
                    graph_data.addColumn('number', 'Sales');
                    
                    console.log(data);
                        
                    $.each(data, function(i,v) {
                        graph_data.addRow([{v: $.datepicker.parseDate("dd-mm-yy", v.date), f: v.period}, {v: v.total, f: v.formatted_total}]);
                    });
                    chart.draw(graph_data, options);
                }
            });
        }
        
        $('#graph-controls .period').on('click', 'a', function(e) {
            e.preventDefault();
            
            var $li = $(this).closest('li');
            if ($li.hasClass("current")) return;
            
            graph_period = $li.data('val');
            $li.closest('ul').find('.current').removeClass('current');
            $li.addClass('current');
            
            redrawGraph();
        });
        
        $('#graph-controls .data-type').on('click', 'a', function(e) {
            e.preventDefault();
            
            var $li = $(this).closest('li');
            if ($li.hasClass("current")) return;
            
            graph_type = $li.data('val');
            $li.closest('ul').find('.current').removeClass('current');
            $li.addClass('current');
            
            redrawGraph();
        });
        
        redrawGraph();
    });
}

