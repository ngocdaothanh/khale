-module(h_openid).
-user_module(true).

-compile(export_all).

-include("sticky.hrl").

login_link() -> {a, [{href, ale:path(openid, login)}], "OpenID"}.

logout_link() -> {a, [{href, ale:path(user, logout)}], ?T("Logout")}.

render(User) ->
    Email  = User#user.extra_data,
    OpenId = User#user.indexed_data,
    {
        ale:gravatar(Email, p_user:avatar_size()),
        yaws_api:htmlize(OpenId)
    }.
