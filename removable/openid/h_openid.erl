-module(h_openid).
-user_module(true).

-compile(export_all).

-include("sticky.hrl").

login_link() -> {a, [{href, ale:url_for(openid, login)}], "OpenID"}.

logout_link() -> {a, [{href, ale:url_for(user, logout)}], ?T("Logout")}.

render(User) ->
    OpenId = User#user.data,
    yaws_api:htmlize(OpenId).
