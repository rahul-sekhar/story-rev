$(document).ready(function() {
    var $body = $('body');
    
    // Skip this code if we aren't on a product page
    if (!$body.hasClass('themes')) return;
    
    // Convert the tables to editable ones
    var $themeTable = $('#theme-table')
    $themeTable.itemTable({
        objectName: 'theme',
        selectable: true,
        columns: [
            {
                name: 'Icon',
                field: 'icon_url',
                type: 'image',
                image_id_field: 'icon_id',
                image_url: '/admin/theme_icons.json',
                raw: 'icon_data_json'
            },
            {
                name: 'Name',
                field: 'name',
            },
        ]
    });
    
    // When the theme table changes, construct a product table for that theme
    var $themeLink = $('<a href="#">Select products from a list</a>');
    var $productTable = $('#theme-product-table');
    $themeTable.on("selectionChange", function(e, id) {
        $productTable.empty();
        if (!id) return;
        
        $productTable.itemTable({
            url: '/admin/themes/' + id + '/products',
            objectName: 'product',
            initialLoad: true,
            selectable: false,
            numbered: true,
            editable: false,
            addable: false,
            columns: [
                {
                    name: 'Title',
                    field: 'title'
                },
                {
                    name: 'Author Name',
                    field: 'author_name'
                },
                {
                    name:'Age Level',
                    field: 'age_level'
                },
                {
                    name:'In Stock',
                    field: 'in_stock',
                    displayCallback: function(data) {
                        return (data ? "In Stock" : "");
                    }
                }
            ]
        });
        $themeLink.attr('href', '/admin/themes/' + id).insertAfter($productTable);
    });
});