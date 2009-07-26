-module(m_user).

-compile(export_all).

-include("sticky.hrl").

migrate() ->
    m_helper:create_table(user, record_info(fields, user)).

%% Returns the list of user/login modules. These modules provide user login feature.
%%
%% A user module should:
%% * define -user_module(true).
%% * Implements login_link/0, logout_link/0, render_user/1.
modules() ->
    ale:cache("khale_user_modules", fun() ->
        filelib:fold_files(?ALE_ROOT ++ "/ebin", "^h_.*\.beam$", false,
            fun(ModelFile, Acc) ->
                Base = filename:basename(ModelFile, ".beam"),
                Module = list_to_atom(Base),
                code:ensure_loaded(Module),
                Attributes = Module:module_info(attributes),
                case proplists:get_value(user_module, Attributes) of
                    [true] -> [Module | Acc];
                    _      -> Acc
                end
            end,
            []
        )
    end).

type_to_module(Type) -> list_to_atom([$h, $_ | atom_to_list(Type)]).

more(LastUserId) ->
    {atomic, Users} = mnesia:transaction(fun() ->
        Q1 = case LastUserId of
            undefined -> qlc:q([R || R <- mnesia:table(user)]);
            _         -> qlc:q([R || R <- mnesia:table(user), R#user.id < LastUserId])
        end,
        Q2 = qlc:keysort(1 + 1, Q1, [{order, descending}]),  % sort by id
        QC = qlc:cursor(Q2),
        Users2 = qlc:next_answers(QC, ?ITEMS_PER_PAGE),
        qlc:delete_cursor(QC),
        Users2
    end),
    Users.

find(Id) ->
    Q = qlc:q([R || R <- mnesia:table(user), R#user.id == Id]),
    case m_helper:do(Q) of
        [R] -> R;
        _   -> undefined
    end.

% FIXME
contents(User) ->
    Contents = [],
    % {atomic, Contents} = mnesia:transaction(fun() ->
    %     Q1 = qlc:q([R || R <- mnesia:table(content), R#content.user_id == User#user.id]),
    %     Q2 = qlc:keysort(5, Q1, [{order, descending}]),  % Reverse sort by created_at
    %     qlc:e(Q2)
    % end),
    Contents.

num_contents(User) -> length(contents(User)).
