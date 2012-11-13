$(document).ready(function() {
    var $body = $('body');
    
    // Stock taking section
    if (!$body.hasClass('stock-taking')) return;
    
    $('#stock-table').itemTable({
        url: '/admin/copies',
        objectName: 'copy',
        selectable: false,
        editable: false,
        addable: false,
        headings: true,
        sortable: true,
        columns: [
            {
                name: 'Acc No.',
                field: 'accession_id',
                sort_by: 'accession_id_sortable',
                default_sort: 'asc'
            },
            {
                name: 'Title',
                field: 'title',
                sort_by: 'title',
            },
            {
                name: 'Author',
                field: 'author_name',
                sort_by: 'author_name',
            },
            {
                name: 'Format',
                field: 'format_name',
            },
            {
                name: 'Condition',
                field: 'condition_rating',
                type: 'rating'
            },
            {
                name: 'Price',
                field: 'price',
            },
            {
                name: 'More Information',
                class_name: 'has-button',
                noHeading:true
            },
            {
                name: 'Stock',
                field: 'stock',
                noHeading: true
            }
        ]
    }).on('click', '.grey-ticked-link', function(e) {
        e.preventDefault();
        
        var $link = $(this);
        var copy_id = $link.closest('tr').data('id');
        $link.removeClass().addClass('loading-link');
        
        $.post('/admin/stock_taking/add_copy', {copy_id: copy_id}, function(data) {
            update_stock($link, data.stock);
        });
    }).on('click', '.ticked-link', function(e) {
        e.preventDefault();
        
        var $link = $(this);
        var copy_id = $link.closest('tr').data('id');
        $link.removeClass().addClass('loading-link');
        
        $.post('/admin/stock_taking/remove_copy', {_method: 'DELETE', copy_id: copy_id}, function(data) {
            update_stock($link, data.stock);
        });
    })
    
    function update_stock($link, stock) {
        $link.removeClass().addClass(stock ? 'ticked-link' : 'grey-ticked-link');
        
        if (stock)
            $link.closest('tr').addClass('stocked');
        else
            $link.closest('tr').removeClass('stocked');
    }
});