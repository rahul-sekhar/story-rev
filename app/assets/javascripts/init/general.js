// jQuery UI settings
$.extend($.ui.dialog.prototype.options, {
    modal: true,
    resizable: false,
    draggable: false,
    show: 'fade',
    hide: 'fade'
});

// Initialize ajax settings
$.ajaxSetup({
    type: "POST",
    dataType: "json"
});

// HTML Escaping function
function escapeHTML(data) {
        return data ? $('<div />').text(data).html() : '';
}

// Function to check whether a link was click such that it should open in a new page/tab
function extClick(e) {
    return (e.ctrlKey || e.metaKey || e.shiftKey || e.which == 2);
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

// Function to resize the jquery UI blocking overlay
function resizeOverlay() {
    $('.ui-widget-overlay').width($(document).width())
        .height($(document).height());
}

// Keycode constants
var KEYCODE_ESC = 27;

// Reset dialog positions to the center
function resetDialogPositions () {
    $('.dialog:visible').dialog('option', 'position', 'center');
}

// Function to close the other dialogs
function closeOtherDialogs(id) {
    $('.dialog:visible:not(' + id + ')').each(function() {
        var $this = $(this);
        if ($this.dialog("isOpen") === true)
            $this.dialog("close");
    });
}

// Plguin to serialize to a JSON object
$.fn.serializeObject = function()
{
    var o = {};
    var a = this.serializeArray();
    $.each(a, function() {
        if (o[this.name] !== undefined) {
            if (!o[this.name].push) {
                o[this.name] = [o[this.name]];
            }
            o[this.name].push(this.value || '');
        } else {
            o[this.name] = this.value || '';
        }
    });
    return o;
};

$(document).ready(function() {
    var $body = $('body');
    
    // Handle external links
    $body.on('click', 'a.ext', function(e) {
        window.open(this.href);
        e.preventDefault();
    });
    
    // Email obfuscation [delay for a second in case that helps to prevent spam]
    var $emailLinks = $('.email_obf');
    if ($emailLinks.length) {
        setTimeout(function() {
            
            // Email obfuscator script 2.1 by Tim Williams, University of Arizona
            // Random encryption key feature by Andrew Moulden, Site Engineering Ltd
            // This code is freeware provided these four comment lines remain intact
            // A wizard to generate this code is at http://www.jottings.com/obfuscator/
            coded = "2avini8Qv4baEv3@WhLE4.Pvh"
            key = "7wjzyc2dJeNCHZhLiBD59MAv4S0tFnPugY86G1UXKExsfIpRQTkmar3qbWOVol"
            shift = coded.length;
            link = "";
            for (i=0; i<coded.length; i++) {
                if (key.indexOf(coded.charAt(i))==-1) {
                    ltr = coded.charAt(i);
                    link += (ltr);
                }
                else {     
                    ltr = (key.indexOf(coded.charAt(i)) - shift+key.length) % key.length;
                    link += (key.charAt(ltr));
                }
            }
            
            $emailLinks.html('<a href="mailto:' + link + '">' + link + '</a>');
        }, 1000);
    }
    
    // Notice dialog
    var $noticeDialog = $('<section id="notice-dialog" class="dialog"></section>');
    $noticeDialog.dialog({
        position: "center",
        width: 400,
        autoOpen:false
    });
    
    var $message = $('<p class="message"></p>').appendTo($noticeDialog);
    var $okButton = $('<a href="#" class="button">Okay</a>').click(function(e) {
        e.preventDefault();
        $noticeDialog.dialog("close");
    }).appendTo($noticeDialog).wrap('<div class="button-holder"></div>');
    
    // Global function to handle errors
    displayError = function(xhr, callback) {
        var message = (xhr.responseText && xhr.responseText.length < 500) ? xhr.responseText : "The server cannot be reached";
        displayNotice(message, callback)
    };
    
    // Global function for notices
    displayNotice = function(message, buttonText, callback) {
        
        buttonText = buttonText || "Okay";
        
        $message.text(message);
        $okButton.text(buttonText);
        $noticeDialog.dialog("open");
        resetDialogPositions();
        
        if (callback)
            $noticeDialog.dialog('option', 'hide', null)
        else
            $noticeDialog.dialog('option', 'hide', 'fade')
        
        $noticeDialog.one("dialogclose", callback);
    }
    
    // Reposition any visible dialogs whenever a dialog closes
    $body.on('dialogclose', function() {
        resetDialogPositions();
    });
});