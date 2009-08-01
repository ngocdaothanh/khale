-module(m_discussion).

-compile(export_all).

-include("sticky.hrl").

migrate() -> m_helper:create_table(discussion, record_info(fields, discussion)).

create(ContentType, ContentId, Body, UserId) ->
    mnesia:transaction(fun() ->
        Id = m_helper:next_id(discussion),
        CreatedAt = erlang:universaltime(),
        Discussion = #discussion{
            id = Id,
            content_type = ContentType, content_id = ContentId,
            body = Body,
            user_id = UserId,
            created_at = CreatedAt, updated_at = CreatedAt
        },
        mnesia:write(Discussion)
    end).

find(Id) ->
    Q = qlc:q([R || R <- mnesia:table(discussion), R#discussion.id == Id]),
    case qlc:do(Q) of
        [R] -> R;
        _   -> undefined
    end.

count(ContentType, ContentId) ->
    {atomic, L} = mnesia:transaction(fun() ->
        Q = qlc:q([undefined || R <- mnesia:table(discussion), R#discussion.content_type == ContentType, R#discussion.content_id == ContentId]),
        qlc:e(Q)
    end),
    length(L).

last(ContentType, ContentId) ->
    {atomic, Discussion} = mnesia:transaction(fun() ->
        Q1 = qlc:q([R || R <- mnesia:table(discussion), R#discussion.content_type == ContentType, R#discussion.content_id == ContentId]),
        Q2 = qlc:keysort(2, Q1, [{order, descending}]),
        QC = qlc:cursor(Q2),
        Discussion2 = case qlc:next_answers(QC, 1) of
            [Discussion3] -> Discussion3;
            _          -> undefined
        end,
        qlc:delete_cursor(QC),
        Discussion2
    end),
    Discussion.

% LastDiscussionId: last id of the last more.
more(ContentType, ContentId, LastDiscussionId) ->
    % OPTIMIZE: sort by updated at ~ sort by id
    {atomic, Discussions} = mnesia:transaction(fun() ->
        Q1 = case LastDiscussionId of
            undefined -> qlc:q([R || R <- mnesia:table(discussion), R#discussion.content_type == ContentType, R#discussion.content_id == ContentId]);
            _         -> qlc:q([R || R <- mnesia:table(discussion), R#discussion.content_type == ContentType, R#discussion.content_id == ContentId, R#discussion.id < LastDiscussionId])
        end,
        Q2 = qlc:keysort(1 + 1, Q1, [{order, descending}]),
        QC = qlc:cursor(Q2),
        Discussions2 = qlc:next_answers(QC, ?ITEMS_PER_PAGE),
        qlc:delete_cursor(QC),
        Discussions2
    end),
    Discussions.