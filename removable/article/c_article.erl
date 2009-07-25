-module(c_article).

-compile(export_all).

-include("sticky.hrl").

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
