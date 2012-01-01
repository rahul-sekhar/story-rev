function escapeHTML(data) {
    if (data) {
        return $('<div />').text(data).html();
    }
    else {
        return '';
    }
}

function makeOption(value, text) {
    return '<option value="' + value + '">' + text + '</option>';
}

$.fn.appendOption = function(value, text) {
    return $(this).append(makeOption(value, text));
}