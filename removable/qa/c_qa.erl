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
        false -> {struct, [{error, ?WRONG_MATHCHA}]};

        true ->
            TagNames = ale:params(tags),

            ErrorOrAtomic = case Which of
                create ->
                    Qa = #qa{
                        user_id = h_application:user_id(), ip = ale:ip(),
                        question = ale:params(question), detail = ale:params(detail)
                    },
                    m_qa:create(Qa, TagNames);

                update ->
                    Id = list_to_integer(ale:params(id)),
                    Qa = m_qa:find(Id),
                    Qa2 = Qa#qa{
                        ip = ale:ip(),
                        question = ale:params(question), detail = ale:params(detail)
                    },
                    m_qa:update(Qa2, TagNames)
            end,

            case ErrorOrAtomic of
                {error, Error} -> {struct, [{error, Error}]};
                {atomic, Qa3}  -> {struct, [{atomic, Qa3#qa.id}]}
            end
    end,
    ale:view(undefined),
    ale:yaws(content, "application/json", json:encode(Data)).
