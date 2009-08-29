-module(v_event_show).

-compile(export_all).

-include("sticky.hrl").
-include("event.hrl").

render() ->
    ale:app(title_in_body, h_event:render_name()),

    Event = ale:app(event),
    TitleInHead = h_event:render_title(Event),
    ale:app(title_in_head, TitleInHead),

    User = m_user:find(Event#event.user_id),
    Rows = lists:map(
        fun(Participant) ->
            P = m_user:find(Participant#participant.user_id),
            {tr, [], [
                {td, [], h_user:render(P)},
                {td, [], yaws_api:htmlize(Participant#participant.participant_note)},
                {td, [], yaws_api:htmlize(Participant#participant.invitor_note)}
            ]}
        end,
        Event#event.participants
    ),
    [
        {h1, [], h_event:render_title(Event)},
        h_event:render_header(User, Event),
        {'div', [], Event#event.invitation},

        {table, [], [
            {tr, [], [
                {th, [], ?T("Participant")},
                {th, [], ?T("Participant note")},
                {th, [], ?T("Invitor note")}
            ]}
        ] ++ Rows},

        h_discussion:render_all(event, Event#event.id)
    ].
