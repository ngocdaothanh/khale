-module(c_poll).

-routes([
    get,    "/polls/new",      new,
    get,    "/polls/:id",      show,
    post,   "/polls",          create,
    put,    "/polls/:id",      update,
    delete, "/polls/:id",      delete
]).

-compile(export_all).

-include("sticky.hrl").
-include("poll.hrl").

%-------------------------------------------------------------------------------

show() ->
    Id = list_to_integer(ale:params(id)),
    ale:app(poll, m_poll:find(Id)).

new() -> ok.

create() ->
    Answer = ale:params(answer),
    EncryptedAnswer = ale:params(encrypted_answer),
    Data = case ale:mathcha(Answer, EncryptedAnswer) of
        false -> {struct, [{error, ?T("The result for the simple math problem is wrong!")}]};

        true ->
            TagNames = ale:params(tags),
            Poll = #poll{
                user_id = h_application:user_id(), ip = ale:ip(),
                question = ale:params(question), choices = ale:params("choices[]"), deadline_on = ale:params(deadline_on)
            },
            case m_poll:create(Poll, TagNames) of
                {error, Error}  -> {struct, [{error, Error}]};
                {atomic, Poll2} -> {struct, [{atomic, Poll2#poll.id}]}
            end
    end,
    ale:view(undefined),
    ale:yaws(content, "application/json", json:encode(Data)).

%% Votes (edit is not allowed once the poll has been created).
update() ->
    Id     = list_to_integer(ale:params(id)),
    Choice = list_to_integer(ale:params(choice)),
    UserId = h_poll:user_id(),
    m_poll:vote(Id, UserId, Choice),
    ale:view(undefined).
