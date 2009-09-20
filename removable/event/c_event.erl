-module(c_event).

-routes([
    get,    "/events/new",      new,
    get,    "/events/:id",      show,
    post,   "/events",          create,
    get,    "/events/:id/edit", edit,
    put,    "/events/:id",      update,
    delete, "/events/:id",      delete
]).

-compile(export_all).

-include("sticky.hrl").
-include("event.hrl").

%-------------------------------------------------------------------------------

show() ->
    Id = list_to_integer(ale:params(id)),
    ale:app(event, m_event:find_and_inc_views(Id)).

new() -> ok.

create() -> create_or_update(create).

edit() ->
    Id = list_to_integer(ale:params(id)),
    ale:app(event, m_event:find(Id)).

update() ->
    Id = list_to_integer(ale:params(id)),
    Event = m_event:find(Id),
    case h_app:editable(Event) of
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
                    Event = #event{
                        user_id = h_app:user_id(), ip = ale:ip(),
                        name = ale:params(name), invitation = ale:params(invitation),
                        deadline_on = h_app:parse_date(ale:params(deadline_on))
                    },
                    m_event:create(Event, TagNames);

                update ->
                    Id = list_to_integer(ale:params(id)),
                    Event = m_event:find(Id),
                    Event2 = Event#event{
                        ip = ale:ip(),
                        name = ale:params(name), invitation = ale:params(invitation),
                        deadline_on = h_app:parse_date(ale:params(deadline_on))
                    },
                    m_event:update(Event2, TagNames)
            end,

            case ErrorOrAtomic of
                {error, Error}   -> {struct, [{error, Error}]};
                {atomic, Event3} -> {struct, [{atomic, Event3#event.id}]}
            end
    end,
    ale:view(undefined),
    ale:yaws(content, "application/json", json:encode(Data)).
