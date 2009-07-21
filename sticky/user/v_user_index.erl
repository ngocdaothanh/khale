-module(v_user_index).

-compile(export_all).

-include("sticky.hrl").

render() ->
    ale:app(title, ?T("Users")),

    Users = ale:app(users),
    More = case length(Users) < ?ITEMS_PER_PAGE of
        true -> [];

        false ->
            LastUser = lists:last(Users),
            {a, [{onclick, "return more(this)"}, {href, ale:path(index, [LastUser#user.id])}], ?T("More...")}
    end,

    {ul, [{class, users}], [
        [{li, [], p_user:render(U)} || U <- Users],
        More
    ]}.
