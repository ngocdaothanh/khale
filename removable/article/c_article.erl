-module(c_article).

-routes([
    get,    "/articles/new",      new,
    get,    "/articles/:id",      show,
    post,   "/articles",          create,
    get,    "/articles/:id/edit", edit,
    put,    "/articles/:id",      update,
    delete, "/articles/:id",      delete
]).

-compile(export_all).

-include("sticky.hrl").

new() -> ok.

show() ->
    Id = list_to_integer(ale:params(id)),
    ale:app(article, m_article:find(Id)).

create() ->
    T1 = ale:params(title),
    A1 = ale:params(abstract),
    B1 = ale:params(body),
    {ok, T2} = esan:san(T1),
    {ok, A2} = esan:san(A1),
    {ok, B2} = esan:san(B1),

    m_article:create(1, [], T2, A2, B2),
    ale:view(v_content_new).

update(Id) ->
    "update" ++ Id.
