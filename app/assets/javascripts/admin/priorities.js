$(document).ready(function() {
    var $body = $('body');
    if (!$body.hasClass('priorities')) return;
    
    $body.on('click', '.change-link', function(e) {
        e.preventDefault();
        
        var $link = $(this);
        var $li = $link.closest('li');
        var id = $li.data("id");
        var name = $li.data("name");
        var priority = $li.data("priority");
        var object = $li.closest('ul').attr("class");
        var url = "/admin/" + object + "/" + id;
        
        priority = prompt("New priority for " + name, priority);
        
        if (isNaN(parseInt(priority, 10))) return;
        
        params = {};
        params[object.slice(0,-1)] = { priority: priority};
        params['_method'] = "PUT";
        
        $.ajax({
            url: url,
            type: "POST",
            data: params,
            success: function() {
                window.location.reload(true);
            },
            error: function() {
                alert("Failed to change priority");
            }
        })
    })
});