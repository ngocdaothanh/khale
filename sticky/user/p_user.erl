-module(p_user).

-compile(export_all).

-include("sticky.hrl").

-define(GRAVATAR_SIZE, 16).

render(User) ->
    h_facebook:render_user(User).
