$(document).ready(function() {
    var $body = $('body');
    
    // Skip this code if we aren't on a product page
    if (!$body.hasClass('product')) return;
    
    if ($body.hasClass('search')) {
        // Handle the search box
        $('#product-search').tokenInput("/admin/products", {
            overlayHintText: 'Title, author, ISBN or accession number',
            tokenLimit: 1,
            addClass: "fill",
            additionalParams: { search_by: "all", output: "display_target" },
            allowCustom: true,
            addFormatter: function(query) { return "<li>Add a new product - <strong>" + escapeHTML(query) + "</strong></li>" },
            onAdd: function(item) {
                $(this).tokenInput("clear");
                if (item.id) {
                    // Redirect to the edit page
                    window.location.href = '/admin/products/' + item.id + '/edit'
                }
                else {
                    // If the ID is null, redirect to the add page, with the title preset
                    window.location.href = '/admin/products/new?title=' + encodeURIComponent(item.name)
                }
            }
        });
    }
    
    // Handle the editions and copies page
    if ($body.hasClass('editions')) {
        // Convert the tables to editable ones
        var $editionTable = $('#edition-table')
        $editionTable.itemTable({
            objectName: 'edition',
            selectable: true,
            columns: [
                {
                    name: 'ISBN',
                    field: 'isbn'
                },
                {
                    name: 'Format',
                    field: 'format_name',
                    type: 'autocomplete',
                    sourceURL: '/admin/formats',
                    autocompleteSettings: { searchOnFocus: true }
                },
                {
                    name: 'Base Price',
                    field: 'formatted_base_price',
                    raw: 'base_price'
                }
            ]
        });
        
        // When the edition changes, construct a copies table
        var $copyTable = $('#copy-table');
        var editionURL = $editionTable.data("url")
        $editionTable.on("selectionChange", function(e, id) {
            $copyTable.empty();
            if (!id) return;
            
            $copyTable.itemTable({
                url: editionURL + '/' + id + '/copies',
                objectName: 'copy',
                initialLoad: true,
                columns: [
                    {
                        name: 'Accession Number',
                        field: 'accession_id',
                        type: 'read_only'
                    },
                    {
                        name: 'Condition Rating',
                        field: 'condition_rating'
                    },
                    {
                        name: 'Condition Description',
                        field: 'condition_description'
                    },
                    {
                        name: 'Price',
                        field: 'formatted_price',
                        raw: 'price',
                        default_val: $editionTable.find('tr[data-id=' + id + '] td:eq(2)').data("val")
                    }
                ]
            });
        });
    }
    
    // Skip the remaining code if we aren't on a product form page
    if (!$body.hasClass('form')) return;
    
    // Autocompletes
    var singleAutocompleteSettings = {
        tokenLimit: 1,
        addClass: "fill",
        allowCustom: true,
        tokenValue: "name",
        textPrePopulate: true
    }
    var tagAutocompleteSettings = {
        allowCustom: true,
        tokenValue: "name",
        preventDuplicates: true,
        dataPrepopulate: true
    }
    $('#product_author_name').tokenInput("/admin/authors.json", singleAutocompleteSettings);
    $('#product_illustrator_name').tokenInput("/admin/illustrators.json", singleAutocompleteSettings);
    $('#product_publisher_name').tokenInput("/admin/publishers.json", singleAutocompleteSettings);
    $('#product_genre_list').tokenInput("/admin/genres.json", tagAutocompleteSettings);
    $('#product_keyword_list').tokenInput("/admin/keywords.json", tagAutocompleteSettings);
    $('#product_product_tag_list').tokenInput("/admin/product_tags.json", tagAutocompleteSettings);
    
    var $awardList = $('#award-field-list');
    
    // Check when a award type selector is changed
    $awardList.on("change", ".award_type", function() {
        var $awardType = $(this);
        award_type = $awardType.val();
        var $awards = $awardType.next('select');
        $awards.empty();
        
        // Add a new award type with a prompt and an ajax call
        if (award_type == "add") {
            var name = prompt("Enter the name of the award");
            if (name) {
                $awardType.prop("disabled", true);
                $.ajaxCall("/admin/award_types", {
                    method: "POST",
                    data: {name: name},
                    dataContainer: "award_type",
                    success: function(data) {
                        $awardType.find('option[value=add]').before(makeOption(data.id, data.name));
                        $awardType.val(data.id).prop("disabled", false);
                        $awardType.change();
                    },
                    error: function() {
                        $awardType.val("").prop("disabled", false);
                        $awardType.change();
                    }
                });
            }
            else {
                $awardType.val("");
                $awardType.change();
            }
        }
        // Or change the dependent award names selector when the award type is changed
        else if (award_type) {
            $awards.appendOption("", "Loading...");
            $.get('/admin/award_types/' + award_type + '/awards.json', function(data) {
                $awards.empty();
                $.each(data, function(i, val) {
                    $awards.appendOption(val.id, val.name);
                })
                $awards.appendOption("add", "Add")
                $awardType.trigger("changed");
            })
        }
    });
    
    // Check for a change in the award name selector
    $awardList.on("change", ".award_name", function() {
        var $awardName = $(this);
        var $awardType = $awardName.prev('select');
        award_type = $awardType.val();
        
        // Add a new award name to the selected award type with a prompt and an ajax call
        if ($awardName.val() == "add" && award_type && award_type != "add") {
            var name = prompt("Enter the description to add for '" + $awardType.find('option:selected').text() + "'");
            if (name) {
                $awardName.prop("disabled", true);
                $.ajaxCall("/admin/award_types/" + award_type + "/awards", {
                    method: "POST",
                    data: {name: name},
                    dataContainer: "award",
                    success: function(data) {
                        $awardName.find('option[value=add]').before(makeOption(data.id, data.name));
                        $awardName.val(data.id).prop("disabled", false);
                    },
                    error: function() {
                        $awardName.val($awardName.find("option:first").val()).prop("disabled", false);
                    }
                });
            }
            else {
                $awardName.val($awardName.find("option:first").val());
            }
        }
    });
    // Initialize by checking each award type selector
    $awardList.find('.award_type').each(function() {
        // Add an 'add' option
        var $this = $(this).appendOption("add", "Add");
        var $awardName = $this.next('select');
        var type = $awardName.val();
        // Refresh the dependent award name selector, but restore it's original selected value
        // This is to handle cases where the browser keeps the selector value the same as
        // what was previously selected by the user after a page refresh
        $this.one("changed", function() {
            $awardName.val(type);
        }).change();
    });
    
    // Handle award removal [set the award name value to ""]
    $awardList.on("click", ".remove-link", function(e) {
        var $award = $(this).parent('li');
        $award.hide();
        $award.find('.award_type').val("");
        $award.find('.award_name').empty().appendOption("", "Removed").val("");
        e.preventDefault();
    });
    
    // Create an initial template for an award section by cloning the first award section and
    // reseting it
    var $awardTemplate = $awardList.find('li:first').clone()
        .find('.award_type')
            .find('option')
                .removeAttr("selected")
                .end()
            .val("")
            .end()
        .find('.award_name')
            .attr('name', 'product[award_attributes][][award_id]')
            .empty()
            .end()
        .find('.award_year')
            .attr('name', 'product[award_attributes][][year]')
            .val("")
            .end()
        .find('input[type=hidden]')
            .remove()
            .end();
    
    // Handle adding awards
    $('#add-award-link').click(function(e) {
        $awardTemplate.clone().appendTo($awardList);
        e.preventDefault();
    });
    
    // Create a template of the other fields section
    var $otherFields = $('#other-fields');
    var $otherFieldTemplate = $otherFields.find('div:first').clone()
        .find('input')
            .val("")
            .end()
        .find('textarea')
            .text("")
            .end()
        .find('input[type=hidden]')
            .remove()
            .end();
    
    // Handke the addition of other fields
    $('#add-field-link').click(function(e) {
        $otherFieldTemplate.clone().appendTo($otherFields);
        e.preventDefault();
    });
});