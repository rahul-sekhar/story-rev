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
    
    // Handle the addition of other fields
    $('#add-field-link').click(function(e) {
        $otherFieldTemplate.clone().appendTo($otherFields);
        e.preventDefault();
    });
    
    
    // Handle cover images
    
    var $imageDialog = $('<section id="image-dialog"></section>');
    var $progressCont = $('<div id="progress-bar"></div>').hide().appendTo($imageDialog);
    var $progressBar = $('<div></div>').appendTo($progressCont);
    var $progressText = $('<span></span>').appendTo($progressCont);
    var $errorMsg = $('<p class="error"></p>').hide().appendTo($imageDialog);
    var $dialogInfo = $('<p>Choose a file to upload. The image can be up to 2 MB and must be a JPEG, GIF or PNG file</p>').appendTo($imageDialog);
    var jqXHR = null;
    var $cancel = $('<a href="#" class="cancel">Cancel</a>').click(function(e) {
            e.preventDefault();
            if (jqXHR) jqXHR.abort();
            $imageDialog.trigger('exit');
        }).appendTo($imageDialog);
    
    var initDialog = function(errMsg) {
        $progressCont.hide();
        $imageDialog.find('input').show();
        if (errMsg) {
            $errorMsg.text(errMsg).show()
        }
        else {
            $errorMsg.hide();
        }
        $dialogInfo.show();
        $cancel.show();
    };
    
    // Set up the uploader in the dialog
    $('<input type="file" id="image-uploader" name="image_file" />').fileupload({
        dataType: 'json',
        url: '/admin/cover_images',
        singeFileUpload: true,
        add: function(e, data) {
            var file = data.files[0];
            if (file.size > (4 * 1024 * 1024)) {
               $errorMsg.text('The file cannot be more than 4 MB').show();
            }
            else if(!include(["jpg","png","gif"],file.name.slice(-3).toLowerCase()) && (file.name.slice(-4).toLowerCase() != 'jpeg')) {
                 $errorMsg.text('The file is not a valid format').show();
            }
            else {
                jqXHR = data.submit();
                $imageDialog.find('input').hide();
                $dialogInfo.hide();
                $errorMsg.hide();
                $progressBar.css('width', '0');
                $progressText.text('0%');
                $progressCont.fadeIn();
            }
        },
        progress: function (e, data) {
            var progress = parseInt(data.loaded / data.total * 100, 10);
            $progressBar.css('width', progress + '%');
            $progressText.text(progress + '%');
        },
        done: function (e, data) {
            $progressBar.css('width', '100%');
            $progressText.text('100%');
            $imageDialog.find('input').hide();
            $progressCont.fadeOut(function() {
                var jsonData = $.parseJSON(data.jqXHR.responseText);
                $imageDialog.trigger('exit', [jsonData.id, jsonData.url, jsonData.thumb]);
            });
        },
        fail: function (e, data) {
            if (data.errorThrown == "abort") {
                 initDialog('Upload cancelled');
            }
            else {
                initDialog($.parseJSON(data.jqXHR.responseText)[0]);
            }
        }
    }).appendTo($imageDialog);
    
    // Handle the image links to add and clear the cover
    var $cover = $('.cover:first');
    var $coverId = $('#product_cover_image_id');
    $('#upload-cover-link').click(function(e) {
        initDialog();
        $.blockUI({message: $imageDialog});
        $imageDialog.one('exit', function(event, id, url, thumb) {
            if (url) {
                $cover.empty().append('<a href="' + url + '"><img alt="" src="' + thumb + '" /></a>');
                $coverId.attr("name", "product[cover_image_id]").val(id);
            }
            $.unblockUI();
        });
        e.preventDefault();
    });
    
    $('#clear-cover-link').click(function(e) {
        $cover.empty();
        $coverId.attr("name", "product[cover_image_id]").val(null);
        e.preventDefault();
    });
    
    $('#cover-url-link').click(function(e) {
        var url = prompt("Enter the URL:");
        if (url) {
            $cover.empty().append('<a href="' + url + '"><img alt="" src="' + url + '" /></a>')
            $coverId.attr("name", "product[cover_image_url]").val(url);
        }
    });
    
    
    
    // Handle amazon information
    var $sidebar = $('#sidebar');
    var $productList = $sidebar.find('.products');
    var $productInfo = $sidebar.find('.product-info');
    var productInfo = [];
    
    $sidebar.on('click', '.close', function(e) {
        $sidebar.hide();
        e.preventDefault();
    });
    
    var $productTitle = $('#product_title');
    
    // Load amazon data
    $productTitle.blur(function() {
        var title = $(this).val();
        
        if (!$.trim(title)) {
            $sidebar.hide();
            return;
        }
        $sidebar.show()
        if (title == $sidebar.data("title")) return;
        $sidebar.block(blockUILoading);
        $.get('/admin/products/amazon_info.json', {'title': title}, function(data) {
            $productList.empty();
            $productInfo.empty();
            
            if (!data.length) {
                $productList.appendOption("none", "No amazon results found...");
                $sidebar.unblock();
                productInfo = []
                return;
            }
            
            $sidebar.data("title", title)
            $.each(data, function(index, entry) {
                $productList.appendOption(index, entry.title);
            });
            
            productInfo = data;
            
            $sidebar.unblock();
        });
    });
    
    // Show book info on selection change
    $productList.change(function() {
        $productInfo.empty();
        var currProduct = productInfo[$productList.val()];
        $productInfo.append('<div class="cover"><img src="' + currProduct.image + '" alt="" /></div>');
        $.each(currProduct, function(key, val) {
            $productInfo.append('<li><strong>' + key + ': </strong><br />' + val + '</li>');
        });
    });
    
    $productTitle.blur();
});