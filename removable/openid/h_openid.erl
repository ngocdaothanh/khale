-module(h_openid).
-user_module(true).

-compile(export_all).

-include("sticky.hrl").

login_link(Base64Target) -> {a, [{href, ale:path(openid, login, [Base64Target])}], "OpenID"}.

logout_link() -> {a, [{href, ale:path(user, logout)}], ?T("Logout")}.

render(User, AvatarSize) ->
    OpenId = User#user.indexed_data,
    {Email, Fullname} = User#user.extra_data,
    {
        ale:gravatar(Email, AvatarSize, OpenId),
        {b, [], yaws_api:htmlize(Fullname)}
    }.
