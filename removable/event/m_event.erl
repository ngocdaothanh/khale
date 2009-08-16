-module(m_event).

-compile(export_all).

-include("sticky.hrl").
-include("event.hrl").

%-------------------------------------------------------------------------------

migrate() -> m_helper:create_table(event, record_info(fields, event)).

content() -> [{public_creatable, true}].

%-------------------------------------------------------------------------------

find(Id) ->
    Q = qlc:q([R || R <- mnesia:table(event), R#event.id == Id]),
    case m_helper:do(Q) of
        [R] -> R;
        _   -> undefined
    end.

find_and_inc_views(Id) ->
    F = fun() ->
        Q = qlc:q([R || R <- mnesia:table(event), R#event.id == Id]),
        case qlc:e(Q) of
            [Event] ->
                Views = Event#event.views,
                Event2 = Event#event{views = Views + 1},
                mnesia:write(Event2),
                Event2;

            _ -> undefined
        end
    end,
    case mnesia:transaction(F) of
        {atomic, R} -> R;
        _           -> undefined
    end.

%-------------------------------------------------------------------------------

validate(Event) ->
    N1 = Event#event.name,
    I1 = Event#event.invitation,
    case (N1 == undefined) orelse (I1 == undefined) orelse (Event#event.deadline_on == undefined) of
        true -> {error, ?T("Event name, invitation, and registration deadline must not be empty.")};

        false ->
            case esan:san(string:strip(I1)) of
                {error, _} -> {error, ?T("Invitation contains invalid HTML.")};

                {ok, I2} ->
                    N2 = string:strip(N1),
                    case (N2 == "") orelse (I2 == "") of
                        true  -> {error, ?T("Event name, invitation, and registration deadline must not be empty.")};
                        false -> {ok, Event#event{name = N2, invitation = I2}}
                    end
            end
    end.

create(Event, TagNames) ->
    case validate(Event) of
        {error, Error} -> {error, Error};

        {ok, Event2} ->
            F = fun() ->
                Id = m_helper:next_id(event),
                CreatedAt = erlang:universaltime(),
                Event3 = Event2#event{
                    created_at = CreatedAt, updated_at = CreatedAt,
                    id = Id,
                    participants = [], views = 0
                },
                Thread = #thread{content_type_id = {event, Id}, updated_at = CreatedAt},

                mnesia:write(Event3),
                m_tag:tag(event, Id, TagNames),
                mnesia:write(Thread),
                Event3
            end,
            mnesia:transaction(F)
    end.

update(Event, TagNames) ->
    case validate(Event) of
        {error, Error} -> {error, Error};

        {ok, Event2} ->
            F = fun() ->
                UpdatedAt = erlang:universaltime(),
                Event3 = Event2#event{updated_at = UpdatedAt},
                mnesia:write(Event3),

                Id = Event3#event.id,
                m_tag:tag(event, Id, TagNames),
                Thread = #thread{content_type_id = {event, Id}, updated_at = UpdatedAt},
                mnesia:write(Thread),

                Event3
            end,
            mnesia:transaction(F)
    end.

%-------------------------------------------------------------------------------

sphinx_id_title_body_list() ->
    Q = qlc:q([
        {R#event.id, R#event.name, R#event.invitation} ||
        R <- mnesia:table(event)
    ]),
    m_helper:do(Q).
