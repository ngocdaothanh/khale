$('#logout_facebook').click(function() {
    FB.Connect.logout(function() {
        window.location.href = '~s'
    })
});
