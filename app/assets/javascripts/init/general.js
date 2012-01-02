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

// BlockUI Settings
$.blockUI.defaults.applyPlatformOpacityRules = false;
$.blockUI.defaults.css = { 
    padding:        0, 
    margin:         0, 
    width:          '30%', 
    top:            '40%', 
    left:           '35%', 
    textAlign:      'center', 
    color:          '#000', 
    border:         '3px solid #aaa', 
    backgroundColor:'#fff', 
    padding:        '10px'
}
$.blockUI.defaults.overlayCSS = { 
    backgroundColor: '#000', 
    opacity:         0.6 
}