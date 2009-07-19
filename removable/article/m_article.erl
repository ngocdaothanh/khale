-module(m_article).
-content_module(true).

-compile(export_all).

-include("sticky.hrl").

name() -> ?T("Article").

create(UserId, CategoryIds, Title, Abstract, Body) ->
    Id = m_helper:next_id(content),
    CreatedAt = erlang:universaltime(),
    Article = #content{
        id = Id, user_id = UserId, type = article,
        title = Title, data = {Abstract, Body},
        created_at = CreatedAt, updated_at = CreatedAt
    },
    m_content:save(Article, CategoryIds).
