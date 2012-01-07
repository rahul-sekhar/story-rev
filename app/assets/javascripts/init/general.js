// Handle external links
$(document).ready(function() {
    $("a.ext").click(function(e) {
        window.open(this.href);
        e.preventDefault();
    });
});

// HTML Escaping function
function escapeHTML(data) {
    if (data) {
        return $('<div />').text(data).html();
    }
    else {
        return '';
    }
}

// Functions to simplify appending options to a select box
function makeOption(value, text) {
    return '<option value="' + value + '">' + text + '</option>';
}
$.fn.appendOption = function(value, text) {
    return $(this).append(makeOption(value, text));
}

// Function to check if an array includes an item
function include(arr,obj) {
    return (arr.indexOf(obj) != -1);
}