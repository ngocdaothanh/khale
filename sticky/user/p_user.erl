-module(p_user).

-compile(export_all).

-include("sticky.hrl").

-define(GRAVATAR_SIZE, 16).

render(User) ->
    Helper = m_user:helper_module(User),
    [
        ale:gravatar(User#user.email, ?GRAVATAR_SIZE), " ",
        {a, [{href, yaws_api:htmlize(Helper:url(User))}], yaws_api:htmlize(Helper:username(User))}
    ].
