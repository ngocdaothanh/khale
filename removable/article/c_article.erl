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
-include("article.hrl").

%-------------------------------------------------------------------------------

show() ->
    Id = list_to_integer(ale:params(id)),
    ale:app(article, m_article:find_and_inc_views(Id)).

new() -> ok.

create() -> create_or_update(create).

edit() ->
    Id = list_to_integer(ale:params(id)),
    ale:app(article, m_article:find(Id)).

update() ->
    Id = list_to_integer(ale:params(id)),
    Article = m_article:find(Id),
    case h_application:editable(Article) of
        true  -> create_or_update(update);
        false -> {struct, [{error, ?T("Please login.")}]}
    end.

%-------------------------------------------------------------------------------

create_or_update(Which) ->
    Answer = ale:params(answer),
    EncryptedAnswer = ale:params(encrypted_answer),
    Data = case ale:mathcha(Answer, EncryptedAnswer) of
        false -> {struct, [{error, ?T("The result for the simple math problem is wrong!")}]};

        true ->
            T1  = ale:params(title),
            A1 = ale:params(abstract),
            B1 = ale:params(body),
            case (T1 == undefined) orelse (A1 == undefined) orelse (B1 == undefined) of
                true -> {struct, [{error, ?T("Article title, abstract, and body must not be empty.")}]};

                false ->
                    T2 = string:strip(T1),
                    {ok, A2} = esan:san(string:strip(A1)),
                    {ok, B2} = esan:san(string:strip(B1)),

                    Tags = case ale:params(tags) of
                        undefined -> "";
                        X         -> X
                    end,

                    Ip = ale:ip(),
                    ErrorOrAtomic = case Which of
                        create ->
                            UserId = case ale:session(user) of
                                undefined -> undefined;
                                User      -> User#user.id
                            end,
                            m_article:create(UserId, Ip, T2, A2, B2, Tags);

                        update ->
                            Id = list_to_integer(ale:params(id)),
                            m_article:update(Id, Ip, T2, A2, B2, Tags)
                    end,

                    case ErrorOrAtomic of
                        {error, Error}    -> {struct, [{error, Error}]};
                        {atomic, Article} -> {struct, [{atomic, Article#article.id}]}
                    end
            end
    end,
    ale:view(undefined),
    ale:yaws(content, "application/json", json:encode(Data)).
