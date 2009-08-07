%%% http://wiki.developers.facebook.com/index.php/Detecting_Connect_Status

-module(h_facebook).
-user_module(true).

-compile(export_all).

-include("sticky.hrl").

before_layout() ->
    ale:app_add_head({script, [{type, "text/javascript"}, {src, "http://static.ak.connect.facebook.com/js/api_lib/v0.4/FeatureLoader.js.php"}]}),

    Arg = ale:arg(),
    ApiKey = proplists:get_value("facebook_key", Arg#arg.opaque),
    ale:app_add_js("FB.init(\"" ++ ApiKey ++ "\", \"/static/xd_receiver.htm\");").

login_link(Base64Target) ->
    Js = ale:ff("p_facebook_login.js", [Base64Target, ale:path(facebook, login, [Base64Target])]),
    ale:app_add_js(Js),
    {a, [{href, "#"}, {id, ["login_facebook", Base64Target]}], "Facebook"}.

logout_link() ->
    Js = ale:ff("p_facebook_logout.js", [ale:path(user, logout)]),
    ale:app_add_js(Js),
    {a, [{href, "#"}, {id, logout_facebook}], ?T("Logout")}.

render(User, AvatarSize) ->
    Uid  = User#user.indexed_data,
    {
        {'fb:profile-pic', [{uid, Uid}, {width, AvatarSize}]},
        {'fb:name', [{uid, Uid}, {linked, false}, {useyou, false}]}
    }.
