-module(v_user_index).

-compile(export_all).

-include("sticky.hrl").

render() ->
    ale:app(title, ?T("Users")),

    Users = ale:app(users),
    h_application:more(
        Users, users, undefined,
        fun p_user:render/1,
        fun(LastUser) -> ale:path(index, [LastUser#user.id]) end
    ).
