-module(h_user).

-compile(export_all).

-include("sticky.hrl").

-define(AVATAR_SIZE, 32).

%-------------------------------------------------------------------------------

login_links() -> login_links(undefined).

%% Bookmark: after logging in, the user should be redirected to the current
%% path of path#Bookmark.
login_links(Bookmark) ->
    Target = ale:path() ++ case Bookmark of
        undefined -> "";
        _         -> "#" ++ Bookmark
    end,
    Base64Target = base64:encode_to_string(Target),

    [
        {p, [], ?T("Login with")},
        {ul, [],
            [{li, [], M:login_link(Base64Target)} || M <- m_user:modules()]
        }
    ].

%-------------------------------------------------------------------------------

render(User) -> render(User, []).

render(User, Extras) ->
    {Avatar, Name} = case User of
        undefined -> {undefined, ?T("No name")};

        _ ->
            UserModule = m_user:type_to_module(User#user.type),
            UserModule:render(User, ?AVATAR_SIZE)
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
    {table, [{class, user}], [
        {tr, [], [
            {td, [{class, avatar}, {rowspan, 2}], Avatar2},
            {td, [], {a, [{href, ale:path(user, show, [Id])}], Name}}
        ]},
        {tr, [],
            {td, [], Extras4}
        }
    ]}.
