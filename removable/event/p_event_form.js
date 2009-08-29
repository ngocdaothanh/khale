$('#event_form input[type=submit]').click(function() {
    $(this).hide();
    $(this).after('<img class="ajax-loader" src="/static/img/spinner.gif" />');

    tinyMCE.triggerSave();

    var action     = $('#event_form').attr('action');
    var _method    = $('#event_form input[name=_method]').val();
    var name       = $('#event_form input[name=name]').val();
    var invitation = $('#event_form textarea[name=invitation]').val();
    var deadlineOn = $('#event_form input[name=deadline_on]').val();
    var tags       = $('#event_form input[name=tags]').val();
    var answer     = $('#event_form input[name=answer]').val();
    var eAnswer    = $('#event_form input[name=encrypted_answer]').val();
    var postData   = {_method: _method, name: name, invitation: invitation, deadline_on: deadlineOn, tags: tags, answer: answer, encrypted_answer: eAnswer};

    $.post(action, postData, function(data) {
        if (data.error) {
            alert(data.error);
            $('#event_form .ajax-loader').remove();
            $('#event_form input[type=submit]').show();
        } else {
            window.location.href = "/events/" + data.atomic;
        }
    }, "json");
    return false;
});
