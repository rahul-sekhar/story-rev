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
});