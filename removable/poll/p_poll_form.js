$('#poll_form input[type=button]').click(function() {
    $('#poll_form ol').append('<li><input type="text" class="textbox" name="choices[]"></input></li>');
});

$('#poll_form input[type=submit]').click(function() {
    var action   = $('#poll_form').attr('action');
    var question = $('#poll_form input[name=question]').val();
    var choices  = $('#poll_form input[name="choices[]"]').map(function(i, e) {
        var v = jQuery.trim($(e).val());
        if (v != '') return v;  // Empty choice is not included in choices by map
    });
    var tags     = $('#poll_form input[name=tags]').val();
    var answer   = $('#poll_form input[name=answer]').val();
    var eAnswer  = $('#poll_form input[name=encrypted_answer]').val();
    var postData = {question: question, 'choices[]': jQuery.makeArray(choices), tags: tags, answer: answer, encrypted_answer: eAnswer};

    $(this).hide();
    $(this).after('<img class="ajax-loader" src="/static/img/ajax-loader.gif" />');
    $.post(action, postData, function(data) {
        if (data.error) {
            alert(data.error);
            $('#poll_form .ajax-loader').remove();
            $('#poll_form input[type=submit]').show();
        } else {
            window.location.href = "/polls/" + data.atomic;
        }
    }, "json");
    return false;
});
