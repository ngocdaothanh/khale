-module(c_qa).

-routes([
    get,    "/qas/new",      new,
    get,    "/qas/:id",      show,
    post,   "/qas",          create,
    get,    "/qas/:id/edit", edit,
    put,    "/qas/:id",      update,
    delete, "/qas/:id",      delete
]).

-compile(export_all).

-include("sticky.hrl").
-include("qa.hrl").

%-------------------------------------------------------------------------------

show() ->
    Id = list_to_integer(ale:params(id)),
    ale:app(qa, m_qa:find_and_inc_views(Id)).

new() -> ok.

create() -> create_or_update(create).

edit() ->
    Id = list_to_integer(ale:params(id)),
    ale:app(qa, m_qa:find(Id)).

update() ->
    Id = list_to_integer(ale:params(id)),
    Qa = m_qa:find(Id),
    case h_application:editable(Qa) of
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
            Q1 = ale:params(question),
            D1 = ale:params(detail),
            case (Q1 == undefined) orelse (D1 == undefined) of
                true -> {struct, [{error, ?T("Q/A question and detail must not be empty.")}]};

                false ->
                    Q2 = string:strip(Q1),
                    {ok, D2} = esan:san(string:strip(D1)),

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
                            m_qa:create(UserId, Ip, Q2, D2, Tags);

                        update ->
                            Id = list_to_integer(ale:params(id)),
                            m_qa:update(Id, Ip, Q2, D2, Tags)
                    end,

                    case ErrorOrAtomic of
                        {error, Error}    -> {struct, [{error, Error}]};
                        {atomic, Qa} -> {struct, [{atomic, Qa#qa.id}]}
                    end
            end
    end,
    ale:view(undefined),
    ale:yaws(content, "application/json", json:encode(Data)).
