-module(v_user_show).

-compile(export_all).

-include("sticky.hrl").

render() ->
    ale:app(title, ?T("User")),

    User = ale:app(user),
    p_user:render(User).
