-module(m_category).

-compile(export_all).

-include("sticky.hrl").

migrate() ->
    m_helper:create_table(category,         record_info(fields, category)),
    m_helper:create_table(category_content, record_info(fields, category_content), bag).

create(Name, UnixName, Position, UserId) ->
    F = fun() ->
        Id = m_helper:next_id(category),
        Category = #category{
            id = Id,
            name = Name, unix_name = UnixName, position = Position, toc = "",
            user_id = UserId
        },
        ok = mnesia:write(Category),
        Category
    end,
    case mnesia:transaction(F) of
        {atomic, R} -> R;
        _           -> undefined
    end.

all() ->
    Q1 = qlc:q([C || C <- mnesia:table(category)]),
    Q2 = qlc:keysort(1 + 4, Q1, [{order, ascending}]),    % sort by position
    m_helper:do(Q2).

find_by_unix_name(UnixName) ->
    undefined.
