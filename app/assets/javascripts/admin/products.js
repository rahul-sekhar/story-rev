$(document).ready(function() {
    var $body = $('body');
    if (!$body.hasClass('product')) return;
    
    $('#product-search').tokenInput("/admin/products",{
        overlayHintText: 'Title, author, ISBN or accession number',
        tokenLimit: 1,
        addClass: "fill",
        additionalParams: { search_by: "all" },
        allowCustom: true,
        addFormatter: function(query) { return "<li>Add a new product - <strong>" + escapeHTML(query) + "</strong></li>" },
        onAdd: function(item) {
            window.location.href = '/admin/products/' + item.id + '/edit'
        }
    });
    
    
    if (!$body.hasClass('form')) return;
    
    var $awardList = $('#award-field-list');
    
    $awardList.on("change", ".award_type", function() {
        var $awardType = $(this);
        award_type = $awardType.val();
        var $awards = $awardType.next('select');
        $awards.empty();
        
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
    
    $awardList.on("change", ".award_name", function() {
        var $awardName = $(this);
        var $awardType = $awardName.prev('select');
        award_type = $awardType.val();
        
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
    $awardList.find('.award_type').each(function() {
        var $this = $(this).appendOption("add", "Add");
        var $awardName = $this.next('select');
        var type = $awardName.val();
        $this.one("changed", function() {
            $awardName.val(type);
        }).change();
    });
    
    $awardList.on("click", ".remove-link", function(e) {
        var $award = $(this).parent('li');
        $award.hide();
        $award.find('.award_type').val("");
        $award.find('.award_name').empty().appendOption("", "Removed").val("");
        e.preventDefault();
    });
    
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
    
    $('#add-award-link').click(function(e) {
        $awardTemplate.clone().appendTo($awardList);
        e.preventDefault();
    });
    
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
    
    $('#add-field-link').click(function(e) {
        $otherFieldTemplate.clone().appendTo($otherFields);
        e.preventDefault();
    });
});