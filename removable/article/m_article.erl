-module(m_article).
-content_module(true).

-compile(export_all).

-include("sticky.hrl").
-include("article.hrl").

name() -> ?T("Article").

migrate() ->
    m_helper:create_table(article_version, record_info(fields, article_version)).

create(UserId, CategoryIds, Title, Abstract, Body) ->
    Id = m_helper:next_id(content),
    CreatedAt = erlang:universaltime(),
    Article = #content{
        id = Id, user_id = UserId, type = article,
        title = Title, data = {Abstract, Body},
        created_at = CreatedAt, updated_at = CreatedAt
    },
    m_content:save(Article, CategoryIds).
