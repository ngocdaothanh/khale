-module(v_user_index).

-compile(export_all).

-include("sticky.hrl").

render() ->
    Title = ?T("Users"),
    ale:app(title_in_head, Title),
    ale:app(title_in_body, Title),

    Users = ale:app(users),
    h_application:more(
        Users, users, undefined,
        fun h_user:render/1,
        fun(LastUser) -> ale:path(index, [LastUser#user.id]) end
    ).
