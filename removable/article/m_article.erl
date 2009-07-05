-module(m_article).

-compile(export_all).

-include("sticky.hrl").

name() ->
    ?T("Article").

instruction() ->
    ?T("Select if you want to post an article, a notice, a tutorial etc. You can allow everyone to freely edit to improve it.").

create(UserId, CategoryIds, Title, Abstract, Body) ->
    Id = m_helper:next_id(content),
    CreatedAt = erlang:universaltime(),
    Article = #content{
        id = Id, user_id = UserId, content_type = article,
        title = Title, data = {Abstract, Body},
        created_at = CreatedAt, updated_at = CreatedAt
    },
    m_content:save(Article, CategoryIds).

fake() ->
    lists:foreach(
        fun(Args) -> apply(?MODULE, create, Args) end,
        [
            [1, [1, 2], "Calling Erlang from Ruby", "A short abstract", "A long body"],
            [1, [2, 3], "Calling Ruby from Java",   "A short abstract", "A long body"],
            [2, [1, 3], "Calling Java from Erlang", "A short abstract", "A long body"]
        ]
    ).
