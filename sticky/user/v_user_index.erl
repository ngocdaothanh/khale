-module(v_user_index).

-compile(export_all).

-include("sticky.hrl").

render() ->
    Title = ?T("Users"),
    ale:app(title_in_head, Title),
    ale:app(title_in_body, Title),

    Users = ale:app(users),
    h_app:more(
        Users, users,
        fun(User) -> {li, [], h_user:render(User)} end,
        fun(LastUser) -> ale:path(index, [LastUser#user.id]) end
    ).
