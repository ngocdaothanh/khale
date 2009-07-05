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
    Q1 = qlc:q([C || C <- mnesia:table(comment), C#comment.content_id == ContentId]),
    Q2 = qlc:keysort(1 + 5, Q1, [{order, ascending}, {size, 1}]),    % sort by created_at
    case m_helper:do(Q2) of
        [Comment] -> Comment;
        _ -> undefined
    end.
