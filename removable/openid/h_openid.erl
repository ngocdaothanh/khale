-module(h_openid).
-user_module(true).

-compile(export_all).

-include("sticky.hrl").

login_link() -> {a, [{href, ale:path(openid, login)}], "OpenID"}.

logout_link() -> {a, [{href, ale:path(user, logout)}], ?T("Logout")}.

render(User, AvatarSize) ->
    OpenId = User#user.indexed_data,
    {Email, Fullname} = User#user.extra_data,
    {
        ale:gravatar(Email, AvatarSize, OpenId),
        yaws_api:htmlize(Fullname)
    }.
