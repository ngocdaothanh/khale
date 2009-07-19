-module(h_facebook).

-compile(export_all).

-include("sticky.hrl").

before_layout() ->
    ale:app_add_head({script, [{type, "text/javascript"}, {src, "http://static.ak.connect.facebook.com/js/api_lib/v0.4/FeatureLoader.js.php"}]}),

    Arg = ale:arg(),
    ApiKey = proplists:get_value("facebook_key", Arg#arg.opaque),
    ale:app_add_script("FB.init(\"" ++ ApiKey ++ "\", \"/static/xd_receiver.htm\");").

login_link() ->
    ale:app_add_script("
$('#login_facebook').click(function() {
    FB.Connect.requireSession(function() {
        window.location.href = '/facebook'
    })
});
    "),

    {a, [{href, "#"}, {id, login_facebook}], "Facebook"}.

render_user(User) ->
    Uid = User#user.data,
    [
        {'fb:profile-pic', [{uid, Uid}, {'facebook-logo', true}, {size, square}]},
        {'fb:name', [{uid, Uid}, {useyou, false}]}
    ].
