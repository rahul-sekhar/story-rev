$(document).ready(function() {
    var $body = $('body');
    if (!$body.hasClass('themes')) return;
    
    // Convert the tables to editable ones
    var $themeTable = $('#theme-table')
    $themeTable.itemTable({
        objectName: 'theme',
        addLinkText: 'Add Theme',
        selectable: true,
        columns: [
            {
                name: 'Icon',
                field: 'icon_url',
                type: 'image',
                image_id_field: 'icon_id',
                image_url: '/admin/theme_icons.json',
                raw: 'icon_data_json',
                class_name: 'icon'
            },
            {
                name: 'Name',
                field: 'name',
                class_name: 'name'
            },
        ]
    });
    
    // When the theme table changes, construct a product table for that theme
    var $themeLink = $('<a href="#" class="select-link">Select books</a>');
    var $productTable = $('#theme-product-table');
    $themeTable.on("selectionChange", function(e, id) {
        $productTable.empty();
        if (!id) {
            $productTable.parent().next('.select-container').remove();
            return;
        }
        
        $productTable.itemTable({
            url: '/admin/themes/' + id + '/products',
            objectName: 'product',
            initialLoad: true,
            selectable: false,
            editable: false,
            addable: false,
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
                    name:'Age',
                    field: 'age_level',
                    class_name: 'age'
                },
                {
                    name:'Stock',
                    field: 'stock',
                    type: 'numeric',
                    class_name: 'copies'
                },
                {
                    name: 'More Information',
                    class_name: 'has-button',
                    html_content: '<a class="zoom-link" href="#"></a>',
                    type: 'fixed'
                }
            ]
        });
        
        $themeLink.insertAfter($productTable.parent())
            .wrap('<p class="select-container"></p>');
    });
    
    // Build the dialog for selecting books
    var $dialog = $('<section id="select-theme-books"></section>');
    $('<a href="#" class="close-button"></a>').click(function(e) {
        $.unblockUI();
        
        // Refresh the products table
        $themeTable.trigger("selectionChange", $themeTable.itemTable("getSelected"));
        
        e.preventDefault();
    }).appendTo($dialog);
    
    // Dialog table container
    var $dialogTableWrapper = $('<div class="table-wrapper"></div>').appendTo($dialog);
    var $dialogTable = $('<table></table>')
        .appendTo($dialogTableWrapper)
        .wrap('<div class="table-container"></div>');
    
    // To handle blocking of the table when the dialog loads
    var loaded = false;
    $dialogTable.on('tableLoad', function() {
        loaded = true;
        $dialogTableWrapper.unblock();
        
        // Set the table row class for books that are in the theme
        $dialogTable.find('.ticked-link').closest('tr').addClass('in_theme');
    });
    
    // Handle the clicking of links to add books to a theme
    $dialogTable.on('click', '.ticked-link,.add-link', function(e) {
        e.preventDefault();
        
        var $clicked = $(this);
        var $td = $clicked.closest('td');
        var oldVal = $clicked.data('val');
        $clicked.removeClass()
            .addClass('loading-link')
            .data('val', 'loading');
        $td.attr('title', getTooltip('loading'));
        var url = '/admin/themes/' + $dialogTable.data('themeId') + '/products';
        var product_id = $clicked.closest('tr').data('id');
        
        if (oldVal) {
            url += '/' + product_id;
            var data = { _method: 'DELETE'};
        }
        else {
            var data = { product_id: product_id};
        }
        
        $.ajax({
            url: url,
            data: data,
            dataType: 'json',
            type: 'POST',
            success: function(data) {
                $clicked.removeClass()
                    .addClass(data.in_theme ? 'ticked-link' : 'add-link')
                    .data('val', data.in_theme);
                $td.attr('title', getTooltip(data.in_theme));
                
                if (data.in_theme)
                    $clicked.closest('tr').addClass('in_theme');
                else
                    $clicked.closest('tr').removeClass('in_theme');
            },
            error: function(data) {
                $clicked.removeClass().addClass(oldVal ? 'ticked-link' : 'add-link');
                $td.attr('title', getTooltip(oldVal));
            }
        });
    });
    
    // Function to generate tooltips for the add/remove button
    function getTooltip (data) {
        if (data == "loading")
            return 'Loading...';
        else
            return data ? 'Remove from theme' : 'Add to theme'
    }
    
    // Show the book selection dialog when the select book link is clicked
    $('#theme-product-table-wrapper').on('click', '.select-link', function(e) {
        e.preventDefault();
        
        // Get the selected theme
        var id = $themeTable.itemTable("getSelected");
        if (!id) return;
        
        $dialogTable.data('themeId', id);
        
        // Set up the table
        $dialogTable.itemTable({
            url: '/admin/themes/' + id + '/products?all_products=1',
            objectName: 'product',
            initialLoad: true,
            selectable: false,
            editable: false,
            removable: false,
            addable: false,
            headings: true,
            sortable: true,
            blockOnLoad: false,
            containCells: true,
            columns: [
                {
                    name: 'Title',
                    field: 'title',
                    sort_by: 'title',
                    default_sort: 'desc'
                },
                {
                    name: 'Author',
                    field: 'author_name',
                    sort_by: 'author_last_name'
                },
                {
                    name: 'Illustrator',
                    field: 'illustrator_name',
                    sort_by: 'illustrator_last_name'
                },
                {
                    name:'Age',
                    field: 'age_level',
                    sort_by: 'age_from'
                },
                {
                    name: 'Awards',
                    field: 'award_list',
                    class_name: 'awards'
                },
                {
                    name: 'Keywords',
                    field: 'keyword_list',
                    class_name: 'keywords'
                },
                {
                    name:'Stock',
                    field: 'stock',
                    numeric: true,
                    class_name: 'copies'
                },
                {
                    name: 'More Information',
                    class_name: 'has-button',
                    html_content: '<a class="zoom-link" href="#"></a>',
                    type: 'fixed',
                    noHeading:true
                },
                {
                    name: 'In Theme',
                    field: 'in_theme',
                    class_name: 'has-button',
                    type: 'html',
                    noHeading:true,
                    displayCallback: function(data) {
                        return '<a href="#" class="' + (data ? 'ticked-link' : 'add-link') + '"></a>';
                    },
                    tooltipCallback: getTooltip
                }
            ]
        });
        
        loaded = false;
        $.blockUI({
            message: $dialog,
            css: {
                top: '10%',
                width: '80%',
                left: '10%',
                height: '80%'
            },
            onBlock: function() {
                if (!loaded) {
                    $dialogTableWrapper.block({
                        message: $.blockUI.loadingMessage,
                        css: $.blockUI.loadingCss
                    });
                }
            }
        });
    });
});