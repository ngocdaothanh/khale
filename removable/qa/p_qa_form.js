$('#qa_form input[type=submit]').click(function() {
    $(this).hide();
    $(this).after('<img class="ajax-loader" src="/static/img/spinner.gif" />');

    tinyMCE.triggerSave();

    var action   = $('#qa_form').attr('action');
    var _method  = $('#qa_form input[name=_method]').val();
    var question = $('#qa_form input[name=question]').val();
    var detail   = $('#qa_form textarea[name=detail]').val();
    var tags     = $('#qa_form input[name=tags]').val();
    var answer   = $('#qa_form input[name=answer]').val();
    var eAnswer  = $('#qa_form input[name=encrypted_answer]').val();
    var postData = {_method: _method, question: question, detail: detail, tags: tags, answer: answer, encrypted_answer: eAnswer};

    $.post(action, postData, function(data) {
        if (data.error) {
            alert(data.error);
            $('#qa_form .ajax-loader').remove();
            $('#qa_form input[type=submit]').show();
        } else {
            window.location.href = "/qas/" + data.atomic;
        }
    }, "json");
    return false;
});
