-module(partial_user).

-compile(export_all).

-include("sticky.hrl").

render(User) ->
    Helper = model_user:helper_module(User),
    {li, [], [
        gravatar(User#user.email, 30, "g", "identicon"),
        {a, [{href, Helper:url(User)}], Helper:username(User)}
    ]}.

gravatar(Email, Size, Rating, Default) ->
    "".
