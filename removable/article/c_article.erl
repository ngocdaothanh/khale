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
    case h_app:editable(Article) of
        true  -> create_or_update(update);
        false -> {struct, [{error, ?T("Please login.")}]}
    end.

%-------------------------------------------------------------------------------

create_or_update(Which) ->
    Answer = ale:params(answer),
    EncryptedAnswer = ale:params(encrypted_answer),
    Data = case ale:mathcha(Answer, EncryptedAnswer) of
        false -> {struct, [{error, ?WRONG_MATHCHA}]};

        true ->
            TagNames = ale:params(tags),

            ErrorOrAtomic = case Which of
                create ->
                    Article = #article{
                        user_id = h_app:user_id(), ip = ale:ip(),
                        title = ale:params(title), abstract = ale:params(abstract), body = ale:params(body)
                    },
                    m_article:create(Article, TagNames);

                update ->
                    Id = list_to_integer(ale:params(id)),
                    Article = m_article:find(Id),
                    Article2 = Article#article{
                        ip = ale:ip(),
                        title = ale:params(title), abstract = ale:params(abstract), body = ale:params(body)
                    },
                    m_article:update(Article2, TagNames)
            end,

            case ErrorOrAtomic of
                {error, Error}    -> {struct, [{error, Error}]};
                {atomic, Article3} -> {struct, [{atomic, Article3#article.id}]}
            end
    end,
    ale:view(undefined),
    ale:yaws(content, "application/json", json:encode(Data)).
