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

function include(arr,obj) {
    return (arr.indexOf(obj) != -1);
}

// BlockUI Settings
$.blockUI.loadingMessage = '<img src="/images/loading.gif" />';
$.blockUI.loadingCss =  { 
    padding:        '6px 8px 2px 8px',
    borderRadius:   '10px',
    width:          '32px',
    height:         '32px',
    margin:         0, 
    textAlign:      'center', 
    backgroundColor:'#eee', 
    cursor:         'wait' 
};
var blockUILoading = { message: $.blockUI.loadingMessage, css: $.blockUI.loadingCss };

$.blockUI.dialogCss = { 
    padding:        0, 
    margin:         0, 
    width:          '30%', 
    top:            '10%', 
    left:           '35%', 
    textAlign:      'center', 
    color:          '#000', 
    border:         '3px solid #aaa', 
    backgroundColor:'#fff', 
    padding:        '10px'
}

$.blockUI.defaults.applyPlatformOpacityRules = false;
$.blockUI.defaults.css = $.blockUI.dialogCss;
$.blockUI.defaults.overlayCSS = { 
    backgroundColor: '#000', 
    opacity:         0.6 
}