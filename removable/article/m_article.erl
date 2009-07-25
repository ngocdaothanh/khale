-module(m_article).

-compile(export_all).

-include("sticky.hrl").
-include("article.hrl").

content() -> [{public_creatable, true}].

migrate() ->
    m_helper:create_table(article_version, record_info(fields, article_version)).

create(UserId, CategoryIds, Title, Abstract, Body) ->
    Id = m_helper:next_id(content),
    CreatedAt = erlang:universaltime(),
    Data = #article{title = Title, abstract = Abstract, body = Body},
    Article = #content{
        id = Id, user_id = UserId,
        data = Data,
        created_at = CreatedAt, updated_at = CreatedAt
    },
    m_content:save(Article, CategoryIds).

