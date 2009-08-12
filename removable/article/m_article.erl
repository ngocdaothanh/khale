-module(m_article).

-compile(export_all).

-include("sticky.hrl").
-include("article.hrl").

migrate() -> m_helper:create_table(article, record_info(fields, article)).

content() -> [{public_creatable, true}].

find(Id) ->
    Q = qlc:q([R || R <- mnesia:table(article), R#article.id == Id]),
    case m_helper:do(Q) of
        [R] -> R;
        _   -> undefined
    end.

find_and_inc_views(Id) ->
    F = fun() ->
        Q = qlc:q([R || R <- mnesia:table(article), R#article.id == Id]),
        case qlc:e(Q) of
            [Article] ->
                Views = Article#article.views,
                Article2 = Article#article{views = Views + 1},
                mnesia:write(Article2),
                Article2;

            _ -> undefined
        end
    end,
    case mnesia:transaction(F) of
        {atomic, R} -> R;
        _           -> undefined
    end.

create(UserId, Ip, Title, Abstract, Body, Tags) ->
    F = fun() ->
        Id = m_helper:next_id(article),
        CreatedAt = erlang:universaltime(),
        Article = #article{
            id = Id,
            title = Title, abstract = Abstract, body = Body,
            user_id = UserId, ip = Ip,
            created_at = CreatedAt, updated_at = CreatedAt
        },
        Thread = #thread{content_type_id = {article, Id}, updated_at = CreatedAt},

        mnesia:write(Article),
        m_tag:tag(article, Id, Tags),
        mnesia:write(Thread),
        Article
    end,
    mnesia:transaction(F).

update(Id, Ip, Title, Abstract, Body, Tags) ->
    F = fun() ->
        Article = find(Id),
        UpdatedAt = erlang:universaltime(),
        Article2 = Article#article{
            title = Title, abstract = Abstract, body = Body,
            ip = Ip,
            updated_at = UpdatedAt
        },
        Thread = #thread{content_type_id = {article, Id}, updated_at = UpdatedAt},

        mnesia:write(Article2),
        m_tag:tag(article, Id, Tags),
        mnesia:write(Thread),
        Article2
    end,
    mnesia:transaction(F).

%-------------------------------------------------------------------------------

sphinx_id_title_body_list() ->
    Q = qlc:q([
        {R#article.id, R#article.title, R#article.abstract ++ R#article.body} ||
        R <- mnesia:table(article)
    ]),
    m_helper:do(Q).
