(function ($) {

// Default settings
var DEFAULTS = {
    url: null,
    objectName: "object",
    columns: [{
        name: "Column 1",
        field: "column_1",
        raw: null   // If the field has a different display format, this is the raw value field name
    }]
}

// Methods callable on the object
var methods = {
    init: function(options) {
        var settings = $.extend({}, DEFAULTS, options || {});
        
        return this.each(function () {
            if ($(this).data("itemTableObject")) {
                $(this).data("itemTableObject").destroy();
            }
            $(this).data("itemTableObject", new $.ItemTable(this, settings));
        });
    },
    add: function(value, name) {
        this.data("itemTableObject").add(value, name);
        return this;
    }
}

$.fn.itemTable = function (method) {
    // Method calling and initialization logic
    if(methods[method]) {
        return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
    } else {
        return methods.init.apply(this, arguments);
    }
};

$.ItemTable = function(table, settings) {
    
    var $table = $(table);
    
    // Add edit and delete buttons to exisiting items
    $table.find('tr')
        .append('<td><a class="edit-link" href="#">Edit</a></td>')
        .append('<td><a class="delete-link" href="#">Delete</a></td>');
    
    // Construct edit/add dialog
    var $dialog = $('<section class="dialog"></section>').hide().appendTo('body');
    var $dialogForm = $('<form method="POST" action="' + settings.url + '"></form>').appendTo($dialog);
    // Add inputs for each column
    $.each(settings.columns, function(index, value) {
        var field_id = settings.objectName + '_' + (value.raw || value.field);
        var field_name = settings.objectName + '[' + (value.raw || value.field) + ']';
        
        var $div = $('<div class="input"></div>').appendTo($dialogForm);
        $div.append('<label for="' + field_id + '">' + value.name + '</label>')
            .append('<input type="text" id="' + field_id + '" name="' + field_name + '" />');
    });
    // Add submit and cancel buttons
    var $submit = $('<input type="submit" value="Save" />').appendTo($dialogForm);
    $('<a href="#">Cancel</a>').click(function() {
        $.unblockUI();
    }).appendTo($dialogForm);
    // A 'PUT' method parameter to be added to the form for edits
    var $putParam = $('<input type="hidden" name="_method" value="PUT" />');
    
    // Handle the dialog submission
    $submit.click(function(e) {
        $.ajax($dialogForm.attr('action'), {
            type: "POST",
            dataType: "json",
            data: $dialogForm.serialize(),
            success: function(data) {
                
            },
            error: function(data) {
                
            }
        });
        e.preventDefault();
    })
    
    // Edit button handling
    $table.on("click", ".edit-link", function(e) {
        var $tr = $(this).closest('tr');
        // Fill dialog fields
        $.each(settings.columns, function(index, value) {
            var field_id = settings.objectName + '_' + (value.raw || value.field);
            var field_val = $tr.find('td:eq(' + index + ')').data('val');
            $dialog.find('#' + field_id).val(field_val);
        });
        // Change the URL of the form
        $dialogForm.attr('action', settings.url + '/' + $tr.data("id"));
        // Add the PUT method parameter
        $putParam.appendTo($dialogForm);
        // Show the dialog box
        $.blockUI({ message: $dialog });
        e.preventDefault();
    });
    
    restripe();
    
    function restripe() {
        $table.find('tr').removeClass('alt').filter(':odd').addClass('alt');
    }
}

}(jQuery));