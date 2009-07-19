-module(p_user).

-compile(export_all).

-include("sticky.hrl").

render(User) ->
    render(User, []).

render(User, Extras) ->
    {Avatar, Name} = case User of
        undefined -> {undefined, ?T("No name")};

        _ ->
            UserModule = m_user:type_to_module(User#user.type),
            UserModule:render(User)
    end,

    Avatar2 = case Avatar of
        undefined -> {img, [{src, "/static/img/noname.gif"}]};
        _         -> Avatar
    end,

    NumContents = case User of
        undefined -> 0;
        _         -> m_user:num_contents(User)
    end,
    NumContentsText = case NumContents of
        0 -> undefined;
        _ -> ?TF("~p contents", [NumContents])
    end,

    Extras2 = [NumContentsText | Extras],
    % Join with " | "
    Extras3 = lists:foldl(
        fun(E, Acc) ->
            case E of
                undefined -> Acc;
                _         -> [Acc, " | ", E]
            end
        end,
        [],
        Extras2
    ),
    Extras4 = case lists:flatten(Extras3) of
        [32, 124, 32 | Rest] -> Rest;  % 32, 124, 32: " | "
        X                    -> X
    end,

    Id = User#user.id,
    {table, [], [
        {tr, [], [
            {td, [{rowspan, 2}], Avatar2},
            {td, [], {a, [{href, ale:path(user, show, [Id])}], Name}}
        ]},
        {tr, [],
            {td, [], Extras4}
        }
    ]}.

%% Same as the size of avatars in Facebook Comment Box.
avatar_size() -> 30.
