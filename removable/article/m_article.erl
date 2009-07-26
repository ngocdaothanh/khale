-module(m_article).

-compile(export_all).

-include("sticky.hrl").
-include("article.hrl").

migrate() -> m_helper:create_table(article, record_info(fields, article)).

content() -> [{public_creatable, true}].

create(Title, Abstract, Body, UserId, Ip, CategoryIds) ->
    Id = m_helper:next_id(content),
    CreatedAt = erlang:universaltime(),
    Article = #article{
        id = Id,
        title = Title, abstract = Abstract, body = Body,
        user_id = UserId, ip = Ip,
        created_at = CreatedAt, updated_at = CreatedAt
    },
    m_content:save(Article, CategoryIds).

find(Id) ->
    Q = qlc:q([R || R <- mnesia:table(article), R#article.id == Id]),
    case m_helper:do(Q) of
        [R] -> R;
        _   -> undefined
    end.
