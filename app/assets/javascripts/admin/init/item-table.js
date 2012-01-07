(function ($) {

// Default settings
var DEFAULTS = {
    url: null,                      // If the URL is left null, it is taken from
                                    // the tables data-url attribute
    objectName: "object",
    selectable: false,
    initialLoad: false,             // If set to true, loads json items from the set URL on creation
    columns: [{
        name: "Column 1",
        field: "column_1",
        
        type: null,                 // If left empty, this defaults to 'text'.
                                    // other options are: 'autocomplete', 'read_only'
        
        sourceURL: null,            // Source URL for autocomplete data
        
        autocompleteSettings: {},   // Options for an autocomplete field
        
        raw: null,                  // If the field has a different display format,
                                    // this is the raw value field name
        
        default_val: null,          // The default value
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
    
    if (!settings.url) {
        settings.url = $table.data("url");
    }
    
    // Handle row selection
    if (settings.selectable) {
        $table.on("click", "tr", function(e) {
            select_item($(this));
        });
    }
    
    // Construct edit/add dialog
    var $dialog = $('<section class="dialog"></section>').hide().appendTo('body');
    var $dialogForm = $('<form method="POST" action="' + settings.url + '"></form>').appendTo($dialog);
    // Add inputs for each column
    $.each(settings.columns, function(index, value) {
        if (value.type == "read_only") return;
        var $div = $('<div class="input"></div>').appendTo($dialogForm);
        $div.append('<label for="' + field_id(value) + '">' + value.name + '</label>');
        constructInput($div, value);
    });
    // Add submit and cancel buttons
    var $submit = $('<input type="submit" value="Save" />').appendTo($dialogForm);
    $('<a href="#">Cancel</a>').click(function() {
        $.unblockUI();
    }).appendTo($dialogForm);
    // A 'PUT' method parameter to be added to the form for edits
    var $putParam = $('<input type="hidden" name="_method" value="PUT" />');
    // A list to display errors
    var $errs = $('<ul class="errors"></ul>');
    
    // Handle the dialog submission
    $submit.click(function(e) {
        $.blockUI({
            message: $.blockUI.loadingMessage,
            css: $.blockUI.loadingCss
        });
        $.ajax($dialogForm.attr('action'), {
            type: "POST",
            dataType: "json",
            data: $dialogForm.serialize(),
            success: function(data) {
                var $tr = $table.find('tr[data-id=' + data.id + ']');
                $newTr = createRow(data);
                
                // Replace row or add a new row
                if ($tr.length)
                    $tr.replaceWith($newTr);
                else
                    $newTr.appendTo($table);
                
                // Select the added/edited row
                if (settings.selectable) select_item($newTr);
                
                // Restripe the table
                restripe();
                
                // Hide the dialog
                $.unblockUI();
            },
            error: function(data) {
                $errs.empty().prependTo($dialog);
                $.each($.parseJSON(data.responseText), function(index, value) {
                    $errs.append('<li>' + value + '</li>');
                });
                
                $.blockUI({message:$dialog});
            }
        });
        e.preventDefault();
    });
    
    // Edit button handling
    $table.on("click", ".edit-link", function(e) {
        var $tr = $(this).closest('tr');
        // Fill dialog fields
        $.each(settings.columns, function(index, value) {
            var field_val = $tr.find('td:eq(' + index + ')').data('val');
            $dialog.find('#' + field_id(value)).val(field_val);
        });
        // Trigger a reset event in all the inputs
        $dialog.find('.dialog-input').trigger("reset");
        // Change the URL of the form
        $dialogForm.attr('action', settings.url + '/' + $tr.data("id"));
        // Add the PUT method parameter
        $putParam.appendTo($dialogForm);
        // Remove the errors list if it has been shown
        $errs.remove();
        // Show the dialog box
        $.blockUI({ message: $dialog });
        return false;
    });
    
    // Delete button handling
    $table.on("click", ".delete-link", function(e) {
        var $tr = $(this).closest('tr');
        $.blockUI({
            message: $.blockUI.loadingMessage,
            css: $.blockUI.loadingCss
        });
        
        $.ajax(settings.url + '/' + $tr.data("id"), {
            type:'POST',
            data: {_method: "DELETE"},
            success: function(data) {
                $tr.remove();
                select_item(null);
                $.unblockUI();
            },
            error: function(data) {
                $.unblockUI();
                $("<span class='flash-error'>That entry could not be deleted</span>").purr();
            }
        })
        return false;
    });
    
    // Load initial items
    if (settings.initialLoad) {
        $.get(settings.url, function(data) {
            $.each(data, function(index, value) {
                $table.append(createRow(value));
            });
            restripe();
        });
    }
    
    // Add edit and delete buttons to exisiting items
    addManageLinks($table.find('tr'))
    
    // Add an add button
    var $addLink = $('<a href="#" class="add-link">Add</a>')
        .click(function(e) {
            // Clear dialog fields or set them to the default
            $.each(settings.columns, function(index, value) {
                $dialog.find('#' + field_id(value)).val(value.default_val || "");
            });
            // Clear and trigger a reset event for all the inputs
            $dialog.find('.dialog-input').trigger("reset");
            // Change the URL of the form
            $dialogForm.attr('action', settings.url);
            // Remove the PUT method parameter if it is present
            $putParam.remove();
            // Remove the errors list if it has been shown
            $errs.remove();
            // Show the dialog box
            $.blockUI({ message: $dialog });
            e.preventDefault();
        }).insertAfter($table);
    
    // Restripe the table
    restripe();
    
    
    // Public functions
    
    this.destroy = function() {
        $table.empty();
        $addLink.remove();
    }
    
    
    // Private functions
    
    function restripe() {
        $table.find('tr').removeClass('alt').filter(':odd').addClass('alt');
    }
    
    function createRow(data) {
        var $tr = $('<tr></tr>').attr("data-id", data.id);
        $.each(settings.columns, function(index, value) {
            $('<td></td>')
                .text(data[value.field] || "")
                .data("val", data[value.raw || value.field] || "")
                .appendTo($tr);
        });
        return addManageLinks($tr);
    }
    
    function field_id(column) {
        return settings.objectName + '_' + (column.raw || column.field);
    }
    
    function field_name(column) {
        return settings.objectName + '[' + (column.raw || column.field) + ']';
    }
    
    
    function constructInput($container, column) {
        var autocompleteDefaults = {
            tokenLimit: 1,
            addClass: "fill thin",
            tokenValue: "name",
            textPrePopulate: true,
            allowCustom: true
        }
        
        var $input = $('<input class="dialog-input" type="text" id="' + field_id(column) + '" name="' + field_name(column) + '" />')
            .attr('autocomplete', 'off')
            .appendTo($container);
        if (column.type == "autocomplete") {
            $input.tokenInput(column.sourceURL, $.extend({}, autocompleteDefaults, column.autocompleteSettings))
                .on("reset", function() {
                    var val = $input.val();
                    $input.tokenInput("reset");
                    
                    if (val)
                        $input.tokenInput("add", {name: val})
                });
        }
    }
    
    function addManageLinks($tr) {
        if ($tr) {
            return $tr.append('<td><a class="edit-link" href="#">Edit</a></td>')
                .append('<td><a class="delete-link" href="#">Delete</a></td>');
        }
    }
    
    // Selection functions
    function select_item($item) {
        var old_selected = get_selected();
        deselect_all();
        if ($item) set_selected($item);
        
        // Check if the selection has changed and trigger an event if so
        var new_selected = get_selected();
        if (new_selected != old_selected) {
            $table.trigger("selectionChange", new_selected);
        }
    }
    
    function set_selected($item) {
        deselect_all();
        $item.addClass('selected');
    }
    
    function get_selected() {
        return $table.find('tr.selected').first().data("id") || null;
    }
    
    function deselect_all() {
        $table.find('tr.selected').removeClass('selected');
    }
}

}(jQuery));