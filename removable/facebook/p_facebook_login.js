$('#login_facebook~s').click(function() {
    FB.Connect.requireSession(function() {
        window.location.href = '~s';
    });
    return false;
});
