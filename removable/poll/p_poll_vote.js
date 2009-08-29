$('#vote').click(function() {
    $(this).hide();
    $(this).after('<img class="ajax-loader" src="/static/img/spinner.gif" />');

    var choice = $('input[name=choice]:checked').val();
    if (choice) {
        $.post("/polls/~p", {_method: "put", choice: choice}, function() {
            window.location.href = "/polls/~p";
        })
    };
});
