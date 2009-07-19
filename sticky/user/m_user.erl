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
    Q = qlc:q([U || U <- mnesia:table(user)]),
    m_helper:do(Q).
