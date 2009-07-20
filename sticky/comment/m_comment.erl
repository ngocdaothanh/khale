%%% Comments are sort by created_at.

-module(m_comment).

-compile(export_all).

-include("sticky.hrl").

migrate() ->
    m_helper:create_table(comment, record_info(fields, comment)).

create(UserId, ContentType, ContentId, Body) ->
    Id = 1,
    CreatedAt = erlang:universaltime(),
    Comment = #comment{id = Id, user_id = UserId,
        content_id = ContentId, body = Body,
        created_at = CreatedAt, updated_at = CreatedAt}.

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

all(ContentId) ->
    Q1 = qlc:q([C || C <- mnesia:table(comment), C#comment.content_id == ContentId]),
    Q2 = qlc:keysort(1 + 5, Q1, [{order, ascending}]),
    m_helper:do(Q2).
