-module(m_category).

-compile(export_all).

-include("sticky.hrl").

migrate() ->
    m_helper:create_table(category,         record_info(fields, category)),
    m_helper:create_table(category_content, record_info(fields, category_content), bag).

create(Name, UnixName, Position) ->
    Id = m_helper:next_id(category),
    Category = #category{id = Id, name = Name, unix_name = UnixName, position = Position},
    mnesia:transaction(fun() -> mnesia:write(Category) end).

all() ->
    Q1 = qlc:q([C || C <- mnesia:table(category)]),
    Q2 = qlc:keysort(1 + 3, Q1, [{order, ascending}]),    % sort by position
    m_helper:do(Q2).

find_by_unix_name(UnixName) ->
    undefined.
