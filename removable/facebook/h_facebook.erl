%%% http://wiki.developers.facebook.com/index.php/Detecting_Connect_Status

-module(h_facebook).
-user_module(true).

-compile(export_all).

-include("sticky.hrl").

before_layout() ->
    ale:app_add_head({script, [{type, "text/javascript"}, {src, "http://static.ak.connect.facebook.com/js/api_lib/v0.4/FeatureLoader.js.php"}]}),

    Arg = ale:arg(),
    ApiKey = proplists:get_value("facebook_key", Arg#arg.opaque),
    ale:app_add_script("FB.init(\"" ++ ApiKey ++ "\", \"/static/xd_receiver.htm\");").

login_link() ->
    Js = ale:ff("p_facebook_login.js", [ale:path(facebook, login)]),
    ale:app_add_script(Js),
    {a, [{href, "#"}, {id, login_facebook}], "Facebook"}.

logout_link() ->
    Js = ale:ff("p_facebook_logout.js", [ale:path(user, logout)]),
    ale:app_add_script(Js),
    {a, [{href, "#"}, {id, logout_facebook}], ?T("Logout")}.

render(User, AvatarSize) ->
    Uid  = User#user.indexed_data,
    {
        {'fb:profile-pic', [{uid, Uid}, {width, AvatarSize}]},
        {'fb:name', [{uid, Uid}, {linked, false}, {useyou, false}]}
    }.
