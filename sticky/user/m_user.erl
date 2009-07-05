-module(m_user).

-compile(export_all).

-include("sticky.hrl").

migrate() ->
    m_helper:create_table(user, record_info(fields, user)).

find(Id) ->
    Q = qlc:q([U || U <- mnesia:table(user), U#user.id == Id]),
    [User] = m_helper:do(Q),
    User.

all() ->
    Q1 = qlc:q([U || U <- mnesia:table(user)]),
    Q2 = qlc:keysort(1 + 1, Q1, [{order, ascending}]),    % sort by id (created order)
    m_helper:do(Q2).

helper_module(User) ->
    list_to_atom("h_" ++ atom_to_list(User#user.type)).
