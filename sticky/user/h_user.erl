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

%% User: undefined = Anonymous
render(User, Extras) ->
    {Avatar, Link} = case User of
        undefined ->
            {
                {img, [{src, "/static/img/anonymous.gif"}, {width, ?AVATAR_SIZE}, {height, ?AVATAR_SIZE}]},
                {b, [], ?T("Anonymous")}
            };

        _ ->
            HModule = m_user:type_to_module(User#user.type),
            {A, N} = HModule:render(User, ?AVATAR_SIZE),
            L = case m_user:num_contents(User) of
                 0 -> N;
                 X -> [N, " | ", {a, [{href, ale:path(user, show, [User#user.id])}], integer_to_list(X)}]
            end,
            {A, L}
    end,

    % Join with " | ", ignoring undefined
    Extras2 = lists:foldl(
        fun(E, Acc) ->
            case E of
                undefined -> Acc;
                _         -> [Acc, " | ", E]
            end
        end,
        [],
        Extras
    ),
    Extras3 = case lists:flatten(Extras2) of
        [32, 124, 32 | Rest] -> Rest;  % 32, 124, 32: " | "
        Y                    -> Y
    end,

    {table, [{class, user}], [
        {tr, [], [
            {td, [{class, avatar}, {rowspan, 2}], Avatar},
            {td, [], Link}
        ]},
        {tr, [],
            {td, [], Extras3}
        }
    ]}.
