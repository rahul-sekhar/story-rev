(function ($) {

// Default settings
var DEFAULTS = {
    url: null,                      // If the URL is left null, it is taken from
                                    // the tables data-url attribute
    objectName: "object",
    addLinkText: "Add",
    tooltips: true,
    numbered: false,
    selectable: false,
    addable: true,
    editable: true,
    removable: true,
    editLinkText: '',
    removeLinkText: '',
    initialLoad: false,             // If set to true, loads json items from the set URL on creation
    blockOnLoad: true,              // Block the table on the initial load
    headings: false,                // Whether to show headings for each column
    sortable: false,                // Whether the table columns can be sorted
    containCells: false,            // If set to true, the content of each cell is placed in a div with class "container"
    
    columns: [{
        name: "Column 1",
        field: "column_1",
        
        multilineLabel: false,      // If set to true, the label is given a multi-line class
        
        type: null,                 // If left empty, this defaults to 'text'.
                                    // other options are: 'autocomplete', 'read_only', 'image',
                                    // 'rating', 'fixed', 'html'
        
        sourceURL: null,            // Source URL for autocomplete data
        
        autocompleteSettings: {},   // Options for an autocomplete field
        
        raw: null,                  // If the field has a different display format,
                                    // this is the raw value field name
        
        image_id_field: null,       // This is the field that the image id can be sent/received from
        
        image_url: "",              // The URL to which the image should be uploaded
        
        default_val: null,          // The default value
        
        class_name: null,           // The column class
        
        html_content: null,         // The HTML content for a fixed column
        
        noHeading: false,           // Whether the column heading is hidden (if headings are enabled)
        
        sort_by: null,              // What attribute to sort the column by - if null, the column cannot be sorted
        
        default_sort: null,         // Whether the column is initially sorted - set to "asc" or "desc" for the order
        
        numeric: false,             // Whether the column has numeric value (So that zeroes are not converted to empty cells)
        
        displayCallback: function(data) { return data; }
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
    
    getSelected: function() {
    	return this.data("itemTableObject").getSelected();
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
    var $tableContainer = $table.parent('.table-container').length ? $table.parent('.table-container') : $table;
    
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
    if (settings.addable || settings.editable) {
        var $dialog = $('<section class="dialog"></section>').hide().appendTo('body');
        var $dialogForm = $('<form method="POST" action="' + settings.url + '"></form>').appendTo($dialog);
        
        // Add inputs for each column
        $.each(settings.columns, function(index, column) {
            if ($.inArray(column.type, ["read_only", "fixed", "custom"]) > -1) return;
            var $div = $('<div class="input"></div>').appendTo($dialogForm);
            $div.append('<label for="' + field_id(column) + '"' + (column.multilineLabel ? ' class="multi-line"' : '') + '>' + column.name + '</label>');
            constructInput($div, column);
        });
        
        // Add submit and cancel buttons
        var $buttonContainer = $('<div class="button-container"></div>').appendTo($dialogForm);
        var $submit = $('<input type="submit" class="minor-button" value="Save" />').appendTo($buttonContainer);
        var $cancel = $('<a href="#" class="minor-button">Cancel</a>').click(function(e) {
            $.unblockUI();
            e.preventDefault();
        }).appendTo($buttonContainer);
        
        // Add a binding for the Escape key
        $dialog.keyup(function(e) {
            if (e.keyCode == KEYCODE_ESC) $cancel.click();
        });
        
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
    }
    
    if (settings.editable) {
        // Edit button handling
        $table.on("click", ".edit-link", function(e) {
            var $tr = $(this).closest('tr');
            // Fill dialog fields
            $.each(settings.columns, function(index, column) {
                var field_val = $tr.find('td:eq(' + index + ')').data('val');
                $dialog.find('#' + field_id(column)).trigger("fill", field_val);
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
    }
    
    if (settings.removable) {
        // Remove button handling
        $table.on("click", ".remove-link", function(e) {
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
                    select_item($table.find('tr.selected:first'));
                    restripe();
                    $.unblockUI();
                },
                error: function(data) {
                    $.unblockUI();
                    $("<span class='flash-error'>That entry could not be deleted</span>").purr();
                }
            })
            return false;
        });
    }
    
    // Add column headings
    if (settings.headings) {
        var $headings = $('<tr class="headings"></tr>');
        $.each(settings.columns, function(index, column) {
            var $th = $('<th></th>');
            
            if (!column.noHeading)
                $th.text(column.name);
            
            // Handle sorting
            if (settings.sortable && column.sort_by) {
                $th.click(function(e) {
                    e.preventDefault();
                    var sort_order = sort_switch($th);
                    sort_by_column(column, index, sort_order);
                }).addClass('sortable')
                .wrapInner('<span></span>');
            }
            
            if (column.class_name)
                $th.addClass(column.class_name);
            
            $th.appendTo($headings);
            
            if(settings.containCells)
                $th.wrapInner('<div class="container"></div>');
        });
        
        $headings.prependTo($table);
    }
    
    // Add edit and delete buttons to exisiting items
    addManageLinks($table.find('tr'), settings)
    
    // Add fixed colums to existing rows
    $.each(settings.columns, function(index, column) {
        if (column.type == "fixed") {
            var $td = $('<td></td>')
                .html(column.html_content);
                
            if(settings.containCells)
                $td.wrapInner('<div class="container"></div>');
            
            if (column.class_name)
                $td.addClass(column.class_name);
            
            if (settings.tooltips)
                setTooltip($td, column);
            
            $table.find("tr td:eq(" + index + ")").before(
                $td.clone()
            )
        }
    });
    
    if (settings.addable) {
        // Add an add button
        var $addLink = $('<a href="#" class="add-link">' + settings.addLinkText + '</a>')
            .click(function(e) {
                // Clear and trigger a reset event for all the inputs
                $dialog.find('.dialog-input').trigger("clear").trigger("reset");
                // Change the URL of the form
                $dialogForm.attr('action', settings.url);
                // Remove the PUT method parameter if it is present
                $putParam.remove();
                // Remove the errors list if it has been shown
                $errs.remove();
                // Show the dialog box
                $.blockUI({ message: $dialog });
                e.preventDefault();
            })
            .insertAfter($tableContainer)
            .wrap('<p class="add-container"></div>');
    }
    
    // Initialize tooltips
    if (settings.tooltips) {
        $table.find('tr').each(function() {
            var $tr = $(this);
            $.each(settings.columns, function(index, column) {
                setTooltip($tr.find('td:eq(' + index + ')'), column);
            });
        });
    }
    
    // Load initial items
    if (settings.initialLoad) {
        
        if (settings.blockOnLoad) {
            $tableContainer.block({
                message: $.blockUI.loadingMessage,
                css: $.blockUI.loadingCss,
                overlayCSS: { 
                    backgroundColor: 'transparent', 
                    opacity: 1
                }
            });
        }
        
        $.get(settings.url, function(data) {
            $.each(data, function(index, value) {
                $table.append(createRow(value));
            });
            restripe();
            
            if (settings.blockOnLoad)
                $tableContainer.unblock();
            
            if (settings.sortable) {
                sort_by_default_column();
            }
            
            $table.trigger('tableLoad');
        });
    }
    else if (settings.sortable) {
        sort_by_default_column();
    }
    
    // Restripe the table
    restripe();
    
    
    // Public functions
    
    this.destroy = function() {
        $table.empty();
        if (settings.addable) {
            $addLink.remove();
        }
    }
    
    this.getSelected = function() {
        return get_selected();
    }
    
    
    // Private functions
    
    function restripe() {
        $table.find('tr').removeClass('alt').filter(':odd').addClass('alt');
        if (settings.numbered) {
            renumber();
        }
    }
    
    function renumber() {
        $table.find('tr').each(function(index, row) {
            var $row = $(row);
            var $number = $row.find('td.number');
            if (!$number.length) $number = $('<td class="number"></td>').prependTo($row);
            $number.text(index + 1)
            if(settings.containCells)
                $number.wrapInner('<div class="container"></div>');
        });
    }
    
    function createRow(data) {
        var $tr = $('<tr></tr>').attr("data-id", data.id);
        $.each(settings.columns, function(index, column) {
            var $td = $('<td></td>');
            
            if (column.type == "image") {
                if (data[column.field]) {
                    $td.html('<img src="' + data[column.field] + '" alt="" />');
                }
            }
            else if (column.type == "rating") {
                var rating = parseInt(data[column.field], 10)
                for (var i = 1; i <= rating; i++) {
                    $td.append('<span class="star">*</span>');
                }
                for (var i = rating; i < 5; i++) {
                    $td.append('<span class="empty star"></span>');
                }
            }
            else if (column.type == "fixed") {
                $td.html(column.html_content);
            }
            else if (column.type == "custom") {
                $td.html(column.displayCallback ? column.displayCallback(data[column.field]) : data[column.field] || "")
            }
            else {
                var text = column.displayCallback ? column.displayCallback(data[column.field]) : data[column.field];
                
                if (!column.numeric)
                    text = text || "";
                
                if (column.type == "html")
                    $td.html(text);
                else {
                    $td.text(text);
                }
            }
            
            if (settings.sortable && column.sort_by) {
                $td.data("sortBy", data[column.sort_by]);
            }
            
            if (column.class_name)
                $td.addClass(column.class_name);
            
            $td.data("val", data[column.raw || column.field] || "")
                .appendTo($tr);
            
            if(settings.containCells)
                $td.wrapInner('<div class="container"></div>');
            
            if (settings.tooltips)
                setTooltip($td, column);
        });
        return addManageLinks($tr, settings);
    }
    
    function setTooltip($td, column) {
        var tooltip = "[" + column.name + "]";
        
        if (column.tooltipCallback) {
            tooltip = column.tooltipCallback($td.data('val'));
        }
        else if (column.type == "image") { }
        else if (column.type == "rating") {
            tooltip += " " + parseInt($td.data('val'), 10) + "/5";
        }
        else if (column.type == "fixed") {
            tooltip = column.name;
        }
        else {
            var cellText = settings.containCells ? $td.children('.container').text() : $td.text();
            tooltip += " " + cellText;
        }
        
        $td.attr("title", tooltip);
    };
    
    function field_id(column) {
        return settings.objectName + '_' + (column.raw || column.field);
    }
    
    function field_name(column) {
        if (column.type == 'image') {
            return settings.objectName + '[' + column.image_id_field + ']';
        }
        return settings.objectName + '[' + (column.raw || column.field) + ']';
    }
    
    
    function constructInput($container, column) {
        
        // Handle images
        if (column.type == "image") {
            var $inputDiv = $('<div class="image dialog-input" id="' + field_id(column) + '"></div>').appendTo($container);
            var $img = $('<img src="" alt="" />').appendTo($inputDiv);
            var $progressText = $('<p class="progress"></p>').appendTo($inputDiv).hide();
            var $imgId = $('<input type="hidden" name="' + field_name(column) + '" />').appendTo($inputDiv);
            var jqXHR = null;
            $('<input type="file" class="image-uploader" name="image_file" />').fileupload({
                dataType: 'json',
                url: column.image_url,
                singeFileUpload: true,
                formData: null,
                add: function(e, data) {
                    var file = data.files[0];
                    if (file.size > (4 * 1024 * 1024)) {
                       $errorMsg.text('The file cannot be more than 2 MB').show();
                    }
                    else if(!include(["jpg","png","gif"],file.name.slice(-3).toLowerCase()) && (file.name.slice(-4).toLowerCase() != 'jpeg')) {
                         $errorMsg.text('The file is not a valid format').show();
                    }
                    else {
                        jqXHR = data.submit();
                        $inputDiv.find('.image-uploader').hide();
                        $progressText.show().text('0%');
                    }
                },
                progress: function (e, data) {
                    var progress = parseInt(data.loaded / data.total * 100, 10);
                    $progressText.text(progress + '%');
                },
                done: function (e, data) {
                    $progressText.hide();
                    $inputDiv.find('.image-uploader').show();
                    var jsonData = $.parseJSON(data.jqXHR.responseText);
                    $img.attr('src', jsonData.url);
                    $imgId.val(jsonData.id);
                }
            }).appendTo($inputDiv);
            
            $inputDiv
                .on("fill", function(e, val) {
                    $img.attr('src', val.url);
                    $imgId.val(val.id);
                })
                .on("clear", function(e) {
                    $img.attr('src', "");
                    $imgId.val(null);
                })
                .on("reset", function(e) {
                    $progressText.hide();
                    $inputDiv.find('.image-uploader').show();
                });
            
            return;
        }
        
        // Handle ratings
        if (column.type == "rating") {
            var $input = $('<input class="dialog-input" type="text" id="' + field_id(column) + '" name="' + field_name(column) + '" />')
                .attr('autocomplete', 'off')
                .appendTo($container)
                .hide();
            
            var $ratingDiv = $('<div class="rating"></div').appendTo($container);
            for (var i = 1; i<=5; i++) {
                $('<div class="star"></div>').data('number', i).appendTo($ratingDiv);
            }
            
            var setRating = function(rating) {
                rating = parseInt(rating, 10);
                
                $ratingDiv
                    .find(".star:lt(" + rating + ")").removeClass("empty").end()
                    .find(".star:gt(" + (rating - 1) + ")").addClass("empty");
            }
            
            $ratingDiv
                .on("click", "div", function() {
                    var rating = $(this).data("number");
                    $input.val(rating);
                    setRating(rating);
                })
                .on("mouseenter", "div", function() {
                    setRating($(this).data("number"));
                })
                .on("mouseleave", "div", function() {
                    setRating($input.val());
                });
            
            $input
                .on("fill", function(e, val) {
                    setRating(val);
                    $input.val(val);
                })
                .on("clear", function(e) {
                    setRating(column.default_val || 3);
                    $input.val(column.default_val || 3);
                });
            
            return;
        }
        
        // Handle other types
        var $input = $('<input class="dialog-input" type="text" id="' + field_id(column) + '" name="' + field_name(column) + '" />')
            .attr('autocomplete', 'off')
            .appendTo($container);
        
        // Handle autocomplete inputs
        if (column.type == "autocomplete") {
            var autocompleteDefaults = {
                tokenLimit: 1,
                addClass: "fill thin dialog",
                tokenValue: "name",
                textPrePopulate: true,
                allowCustom: true
            }
            
            $input.tokenInput(column.sourceURL, $.extend({}, autocompleteDefaults, column.autocompleteSettings))
                .on("reset", function() {
                    var val = $input.val();
                    $input.tokenInput("reset");
                    
                    if (val)
                        $input.tokenInput("add", {name: val})
                });
        }
        
        // Handle ratings
        
        
        // Events for fill and clear triggers
        $input
            .on("fill", function(e, val) {
                $input.val(val);
            })
            .on("clear", function(e) {
                $input.val(column.default_val || "")
            });
    }
    
    function addManageLinks($tr, settings) {
        if ($tr) {
            if (settings.editable) {
                var $editLink = $('<td class="has-button" title="Edit"><a class="edit-link" href="#">' + settings.editLinkText + '</a></td>')
                    .appendTo($tr);
                
                if(settings.containCells)
                    $editLink.wrapInner('<div class="container"></div>');
            }
            if (settings.removable) {
                var $removeLink = $('<td class="has-button last" title="Remove"><a class="remove-link" href="#">' + settings.removeLinkText + '</a></td>')
                    .appendTo($tr);
                
                if(settings.containCells)
                    $removeLink.wrapInner('<div class="container"></div>');
            }
            return $tr;
        }
        else {
            return null;
        }
    }
    
    // Selection functions
    function select_item($item) {
        var old_selected = get_selected();
        deselect_all();
        if ($item) set_selected($item);
        
        // Check if the selection has changed and trigger an event if so
        var new_selected = get_selected();
        if (new_selected === null || new_selected != old_selected) {
            $table.trigger("selectionChange", new_selected);
        }
    }
    
    function set_selected($item) {
        deselect_all();
        $item.addClass('selected');
    }
    
    function get_selected() {
        return $table.find('tr.selected:first').data("id") || null;
    }
    
    function deselect_all() {
        $table.find('tr.selected').removeClass('selected');
    }
    
    // Sorting functions
    function sort_by_column(column, index, order) {
        $table.find('td').filter(function() {
            return $(this).index() === index;
        }).sortElements(function(a,b) {
            var $a = $(a);
            var $b = $(b);
            
            if ($a.data('sortBy') == null)
                return order == "asc" ? -1 : 1;
            if ($b.data('sortBy') == null)
                return order == "asc" ? 1 : -1;
            return $a.data('sortBy') > $b.data('sortBy') ?
                order == "asc" ? -1 : 1
                : order == "asc" ? 1 : -1;
        }, function() {
           return this.parentNode; 
        });
        
        restripe();
    }
    
    var $sortArrow = $('<div class="sort-arrow"></div>');
    
    function sort_by_default_column() {
        $.each(settings.columns, function(index, column) {
            if (column.default_sort) {
                sort_by_column(column, index, column.default_sort);
                var $th = $table.find('tr.headings th:eq(' + index + ')')
                    .addClass('sorting')
                    .data('sortOrder', column.default_sort);
                
                $sortArrow
                    .removeClass("asc")
                    .removeClass("desc")
                    .addClass(column.default_sort);
                
                if (settings.containCells)
                    $th.children('.container').append($sortArrow);
                else
                    $th.append($sortArrow);
                
                return false;
            }td
        });
    }
    
    // Returns the order to sort by
    function sort_switch($th) {
        var sort_order;
        
        if ($th.hasClass('sorting')) {
            sort_order = $th.data('sortOrder') == "desc" ? "asc" : "desc";
        }
        else {
            $table.find('th.sorting')
                .data('sortOrder', null)
                .removeClass('sorting');
            
            $th.addClass('sorting');
            sort_order = "desc";
        }
        
        $sortArrow.removeClass('asc')
            .removeClass('desc')
            .addClass(sort_order);
        
        $th.data('sortOrder', sort_order);
        
        if (settings.containCells)
            $th.children('.container').append($sortArrow);
        else
            $th.append($sortArrow);
        
        return sort_order;
    }
}

}(jQuery));