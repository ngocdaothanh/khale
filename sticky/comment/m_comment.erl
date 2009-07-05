-module(m_comment).

-compile(export_all).

-include("sticky.hrl").

migrate() ->
    m_helper:create_table(comment, record_info(fields, comment)).

create(UserId, ContentType, ContentId, Body) ->
    Id = 1,
    CreatedAt = erlang:universaltime(),
    Comment = #comment{id = Id, user_id = UserId,
        content_type = ContentType, content_id = ContentId, body = Body,
        created_at = CreatedAt, updated_at = CreatedAt}.
