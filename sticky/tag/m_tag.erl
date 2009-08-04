-module(m_tag).

-compile(export_all).

-include("sticky.hrl").

migrate() ->
    m_helper:create_table(tag,         record_info(fields, tag)),
    m_helper:create_table(tag_content, record_info(fields, tag_content), bag).

create(Name) ->
    F = fun() ->
        Id = m_helper:next_id(tag),
        Tag = #tag{id = Id, name = Name},
        ok = mnesia:write(Tag),
        Tag
    end,
    case mnesia:transaction(F) of
        {atomic, R} -> R;
        _           -> undefined
    end.

all() ->
    Q1 = qlc:q([R || R <- mnesia:table(tag)]),
    Q2 = qlc:keysort(3, Q1, [{order, ascending}]),  % sort by name
    m_helper:do(Q2).

find_by_name(Name) ->
    Q = qlc:q([R || R <- mnesia:table(tag), R#tag.name == Name]),
    case m_helper:do(Q) of
        [R] -> R;
        _   -> undefined
    end.
