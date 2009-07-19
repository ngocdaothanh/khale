-module(m_qa).
-content_module(true).

-compile(export_all).

-include("sticky.hrl").

name() -> ?T("Q/A").

create(UserId, CategoryIds, Title, AbstractAndQuestion) ->
    Id = m_helper:next_id(content),
    CreatedAt = erlang:universaltime(),
    Qa = #content{
        id = Id, user_id = UserId, type = qa,
        title = Title, data = AbstractAndQuestion,
        created_at = CreatedAt, updated_at = CreatedAt
    },
    m_content:save(Qa, CategoryIds).
