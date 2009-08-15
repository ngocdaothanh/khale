-module(m_article).

-compile(export_all).

-include("sticky.hrl").
-include("article.hrl").

%-------------------------------------------------------------------------------

migrate() -> m_helper:create_table(article, record_info(fields, article)).

content() -> [{public_creatable, true}].

%-------------------------------------------------------------------------------

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

%-------------------------------------------------------------------------------

validate(Article) ->
    T1 = Article#article.title,
    A1 = Article#article.abstract,
    B1 = Article#article.body,
    case (T1 == undefined) orelse (A1 == undefined) orelse (B1 == undefined) of
        true -> {error, ?T("Article title, abstract, and body must not be empty.")};

        false ->
            case esan:san(string:strip(A1)) of
                {error, _} -> {error, ?T("Abstract contains invalid HTML.")};

                {ok, A2} ->
                    case esan:san(string:strip(B1)) of
                        {error, _} -> {error, ?T("Body contains invalid HTML.")};

                        {ok, B2} ->
                            T2 = string:strip(T1),
                            case (T2 == "") orelse (A2 == "") orelse (B2 == "") of
                                true  -> {error, ?T("Article title, abstract, and body must not be empty.")};
                                false -> {ok, Article#article{title = T2, abstract = A2, body = B2}}
                            end
                    end
            end
    end.

create(Article, TagNames) ->
    case validate(Article) of
        {error, Error} -> {error, Error};

        {ok, Article2} ->
            F = fun() ->
                Id = m_helper:next_id(article),
                CreatedAt = erlang:universaltime(),
                Article3 = Article2#article{id = Id, created_at = CreatedAt, updated_at = CreatedAt},
                mnesia:write(Article3),

                m_tag:tag(article, Id, TagNames),
                Thread = #thread{content_type_id = {article, Id}, updated_at = CreatedAt},
                mnesia:write(Thread),

                Article3
            end,
            mnesia:transaction(F)
    end.

update(Article, TagNames) ->
    case validate(Article) of
        {error, Error} -> {error, Error};

        {ok, Article2} ->
            F = fun() ->
                UpdatedAt = erlang:universaltime(),
                Article3 = Article2#article{updated_at = UpdatedAt},
                mnesia:write(Article3),

                Id = Article3#article.id,
                m_tag:tag(article, Id, TagNames),
                Thread = #thread{content_type_id = {article, Id}, updated_at = UpdatedAt},
                mnesia:write(Thread),

                Article3
            end,
            mnesia:transaction(F)
    end.

%-------------------------------------------------------------------------------

sphinx_id_title_body_list() ->
    Q = qlc:q([
        {R#article.id, R#article.title, R#article.abstract ++ R#article.body} ||
        R <- mnesia:table(article)
    ]),
    m_helper:do(Q).
