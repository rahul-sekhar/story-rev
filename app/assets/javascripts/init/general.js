$(document).ready(function() {
    // Handle external links
    $("a.ext").click(function(e) {
        window.open(this.href);
        e.preventDefault();
    });
    
    // Email obfuscation [delay for a second in case that helps with spam]
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