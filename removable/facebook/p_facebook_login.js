$('#login_facebook').click(function() {
    FB.Connect.requireSession(function() {
        window.location.href = '~s'
    })
});
