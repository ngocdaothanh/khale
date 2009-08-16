-module(v_event_show).

-compile(export_all).

-include("event.hrl").

render() ->
    ale:app(title_in_body, h_event:render_name()),

    Event = ale:app(event),
    TitleInHead = h_event:render_title(Event),
    ale:app(title_in_head, TitleInHead),

    User = m_user:find(Event#event.user_id),
    [
        {h1, [], h_event:render_title(Event)},
        h_event:render_header(User, Event),
        {'div', [], Event#event.invitation},
        h_discussion:render_all(event, Event#event.id)
    ].
