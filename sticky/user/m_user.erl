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

find(Id) ->
    Q = qlc:q([U || U <- mnesia:table(user), U#user.id == Id]),
    [User] = m_helper:do(Q),
    User.

all() ->
    Q = qlc:q([U || U <- mnesia:table(user)]),
    m_helper:do(Q).

num_contents(User) -> 2.