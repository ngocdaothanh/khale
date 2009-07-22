%%% Comments are sort by created_at.

-module(m_comment).

-compile(export_all).

-include("sticky.hrl").

migrate() ->
    m_helper:create_table(comment, record_info(fields, comment)).

create(UserId, ContentId, Body) ->
    mnesia:transaction(fun() ->
        Id = m_helper:next_id(comment),
        CreatedAt = erlang:universaltime(),
        Comment = #comment{id = Id, user_id = UserId,
            content_id = ContentId, body = Body,
            created_at = CreatedAt, updated_at = CreatedAt
        },
        mnesia:write(Comment)
    end).

last(ContentId) ->
    {atomic, Comment} = mnesia:transaction(fun() ->
        Q1 = qlc:q([C || C <- mnesia:table(comment), C#comment.content_id == ContentId]),
        Q2 = qlc:keysort(1 + 5, Q1, [{order, descending}]),
        QC = qlc:cursor(Q2),
        Comment2 = case qlc:next_answers(QC, 1) of
            [Comment3] -> Comment3;
            _          -> undefined
        end,
        qlc:delete_cursor(QC),
        Comment2
    end),
    Comment.

more(ContentId, LastCommentId) ->
    % OPTIMIZE: sort by updated at ~ sort by id
    {atomic, Comments} = mnesia:transaction(fun() ->
        Q1 = case LastCommentId of
            undefined -> qlc:q([R || R <- mnesia:table(comment), R#comment.content_id == ContentId]);
            _         -> qlc:q([R || R <- mnesia:table(comment), R#comment.content_id == ContentId, R#comment.id < LastCommentId])
        end,
        Q2 = qlc:keysort(1 + 1, Q1, [{order, descending}]),
        QC = qlc:cursor(Q2),
        Comments2 = qlc:next_answers(QC, ?ITEMS_PER_PAGE),
        qlc:delete_cursor(QC),
        Comments2
    end),
    Comments.
