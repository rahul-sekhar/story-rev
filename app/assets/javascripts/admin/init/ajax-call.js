(function ($) {

$.ajaxCall = function(url, options) {
    var DEFAULTS = {
        method: 'GET',
        dataType: 'json',
        data: {},
        dataContainer: false,
        success: null,
        error: null,
        purr: true,
        purrSuccess: false,
        getErrorContainer: function(data) {
            return ($("<span class='flash-error'></span>").text(data))
        },
        getSuccessContainer: function(data) {
            return ($("<span class='flash-notice'></span>").text(data))
        }
    };
    
    var opts = $.extend({}, DEFAULTS, options || {});
    if (opts.method == 'PUT' || opts.method == 'DELETE') {
        var type = 'POST';
        var data = { _method: opts.method }
    }
    else {
        var type = opts.method;
        var data = {};
    }
    
    if (opts.dataContainer) {
        var tmp_data = opts.data;
        opts.data = {};
        opts.data[opts.dataContainer] = tmp_data;
    }
    
    $.extend(data, opts.data || {});
    
    $.ajax({
        type: type,
        url: url,
        dataType: opts.dataType,
        data: data,
        success: function(data) {
            if (opts.purr && opts.purrSuccess) {
                $.each(data.messages, function(index, value) {
                    if( typeof(value) == "object") {value = index + " " + value.toString(); }
                    $(opts.getSuccessContainer(value)).purr();
                });
            }
            
            if (opts.success) {
                opts.success(data);
            }
        },
        error: function(data) {
            if (opts.purr) {
                $.each($.parseJSON(data.responseText), function(index,value) {
                    if( typeof(value) == "object") {value = index + " " + value.toString(); }
                    $(opts.getErrorContainer(value)).purr();
                });
            }
            if (opts.error) {
                opts.error(data);
            }
        }
    });
}

}(jQuery));