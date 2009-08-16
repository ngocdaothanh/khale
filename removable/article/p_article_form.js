$('#article_form input[type=submit]').click(function() {
    $(this).hide();
    $(this).after('<img class="ajax-loader" src="/static/img/ajax-loader.gif" />');

    tinyMCE.triggerSave();

    var action   = $('#article_form').attr('action');
    var _method  = $('#article_form input[name=_method]').val();
    var title    = $('#article_form input[name=title]').val();
    var abstract = $('#article_form textarea[name=abstract]').val();
    var body     = $('#article_form textarea[name=body]').val();
    var tags     = $('#article_form input[name=tags]').val();
    var answer   = $('#article_form input[name=answer]').val();
    var eAnswer  = $('#article_form input[name=encrypted_answer]').val();
    var postData = {_method: _method, title: title, abstract: abstract, body: body, tags: tags, answer: answer, encrypted_answer: eAnswer};

    $.post(action, postData, function(data) {
        if (data.error) {
            alert(data.error);
            $('#article_form .ajax-loader').remove();
            $('#article_form input[type=submit]').show();
        } else {
            window.location.href = "/articles/" + data.atomic;
        }
    }, "json");
    return false;
});
