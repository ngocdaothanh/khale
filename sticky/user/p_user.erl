-module(p_user).

-compile(export_all).

-include("sticky.hrl").

render(User) ->
    Helper = m_user:helper_module(User),
    [
        gravatar(User#user.email, 30, "g", "identicon"),
        {a, [{href, yaws_api:htmlize(Helper:url(User))}], yaws_api:htmlize(Helper:username(User))}
    ].

gravatar(Email, Size, Rating, Default) ->
    "".
