-module(v_user_index).

-compile(export_all).

-include("sticky.hrl").

render() ->
    ale:app(title, ?T("Users")),

    Users = ale:app(users),
    NumUsers = length(Users),
    More = case NumUsers < ?ITEMS_PER_PAGE of
        true -> [];

        false ->
            LastUser = lists:last(Users),
            {a, [{id, users_more}, {href, ale:path(index, [LastUser#user.id])}], ?T("More...")}
    end,

    {ul, [{id, users}], [
        [{li, [], p_user:render(U)} || U <- Users],
        More
    ]}.
