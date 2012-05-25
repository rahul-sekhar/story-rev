$(document).ready(function() {
    var $body = $('body');
    if (!$body.hasClass('finances details')) return;
    
    // Table settings for the list of transactions
    var $transactionsTable = $('#transactions-table');
    
    function setOrderTransactionSettings() {
        $transactionsTable.find('tr:not(.headings)[data-order-url]')
            .find('.remove-link').remove().end()
            .find('.edit-link').removeClass('edit-link').addClass('edit-order-link').attr('title', 'Edit Order');
    }
    
    $transactionsTable.on("tableLoad", function(e, data) {
        $.each(data, function(i, val) {
            if (val.order_url) $transactionsTable.find('tr[data-id=' + val.id + ']').attr('data-order-url', val.order_url);
        });
        setOrderTransactionSettings();
    }).on("addedManageLinks", function() {
        setOrderTransactionSettings();
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
    
    // Initialise the date controls and reload the table on a change of date
    initDateControls(function(from_date, to_date) {
        $transactionsTable.itemTable("reload", {
            from: $.datepicker.formatDate("dd-mm-yy", from_date),
            to: $.datepicker.formatDate("dd-mm-yy", to_date)
        });
    });
});

// Function to initialise the date controls
function initDateControls (dateChangeCallback) {
    var $dateControls = $('#date-controls');
    var $fromDate = $dateControls.find('.from');
    var $toDate = $dateControls.find('.to');
    
    var first_date = $.datepicker.parseDate("dd-mm-yy", $dateControls.data("first-date"));
    var from_date = $.datepicker.parseDate("dd-mm-yy", $fromDate.data("date"));
    var to_date = $.datepicker.parseDate("dd-mm-yy", $toDate.data("date"));
    
    $dateControls.find('.datepicker').datepicker({
        dateFormat:"M d, yy",
        gotoCurrent: true,
        onSelect: function(dateText, inst) {
            var $this = $(this);
            var date = $this.datepicker("getDate");
            var $parent = $this.closest('.from, .to');
            if ($parent.hasClass("from")) {
                var option =  "minDate";
                from_date = date;
            }
            else {
                var option =  "maxDate";
                to_date = date;
            }
            $parent.siblings('.from, .to').find('.datepicker').datepicker("option", option, date);
            $parent.find('.date-link').text(dateText);
            $this.fadeOut('fast');
            
            // Call the date change callback function
            dateChangeCallback(from_date, to_date);
        }
    });
    
    // Set max in min ranges for datepickers
    $dateControls.find('.from .datepicker')
        .datepicker("setDate", from_date)
        .datepicker("option", {
            minDate: first_date,
            maxDate: to_date
        });
    
    $toDate.find('.datepicker')
        .datepicker("setDate", to_date)
        .datepicker("option", {
            minDate: from_date,
            maxDate: new Date()
        });
    
    // Handle showing and hiding datepickers
    $dateControls.on("click", ".date-link", function(e) {
        e.preventDefault();
        var $this = $(this);
        $this.closest('.from, .to').siblings('.from, .to').find('.datepicker').fadeOut('fast');
        $this.siblings('.datepicker').fadeToggle();
    });
    
    // Hide datepickers when someone clicks outside them
    $(document).mouseup(function(e) {
        if ($dateControls.has(e.target).length === 0) {
            $dateControls.find('.datepicker').fadeOut('fast');
        }
    });
}


if (typeof google !== 'undefined') {
    google.load('visualization', '1', {'packages':['corechart']});
    google.setOnLoadCallback(function() {
        initGraph();
    });
}

// Function to initialise the graph and load it's data via ajax
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
            hAxis: {
                gridlines: {
                    color:'#E6E6E6'
                },
                direction: -1
            },
            chartArea: {
                left:'10%',
                top:'10%',
                width:"80%",
                height:"70%"
            }
        };
        
        var $graphControls = $('#graph-controls');
        var graph_type = $graphControls.data("type");
        var graph_period = $graphControls.data("period");
        var from = $graphControls.data("from");
        var to = $graphControls.data("from");
        
        // Function to redraw the graph
        function redrawGraph() {
            $.ajaxCall('/admin/transactions/graph_data', {
                purr: false,
                data: {
                    period: graph_period,
                    type: graph_type,
                    from: from,
                    to: to
                },
                success: function(data) {
                    var graph_data = new google.visualization.DataTable();
                    $.each(data.cols, function(i, val) {
                        graph_data.addColumn(val);
                    });
                    var target_url = window.location.pathname + '?' + $.param({
                        from: from,
                        to: to,
                        period: graph_period,
                        type: graph_type
                    })
                    
                    history.replaceState(null, null, target_url);
                    graph_data.addRows(data.rows);
                    chart.draw(graph_data, options);
                }
            });
        }
        
        // Change the graph when the user changes control options
        $graphControls.find('.period, .data-type').on('click', 'a', function(e) {
            e.preventDefault();
            
            var $li = $(this).closest('li');
            if ($li.hasClass("current")) return;
            var $ul = $li.closest('ul');
            
            if ($ul.hasClass('period'))
                graph_period = $li.data('val');
            else
                graph_type = $li.data('val');
            
            $ul.find('.current').removeClass('current');
            $li.addClass('current');
            
            redrawGraph();
        });
        
        var $summary = $('.summary:first');
        // Initialise the date controls and change the page each time they're changed
        initDateControls(function(from_date, to_date) {
            from = $.datepicker.formatDate("dd-mm-yy", from_date);
            to = $.datepicker.formatDate("dd-mm-yy", to_date);
            
            $.get('/admin/transactions/summarised', {
                    from: from,
                    to: to
                }, function(data) {
                    $.each(data, function(key, val) {
                        $summary.find('.' + key + ' .amount').text(val);
                    })
                }, 'json');
            
            redrawGraph();
        });
        
        // Draw the inital graph
        redrawGraph();
    });
}

