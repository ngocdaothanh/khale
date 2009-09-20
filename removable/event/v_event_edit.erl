-module(v_event_edit).

-compile(export_all).

-include("sticky.hrl").
-include("event.hrl").

render() ->
    Title = ?T("Edit Q/A"),
    ale:app(title_in_head, Title),
    ale:app(title_in_body, Title),

    Event = ale:app(event),
    case h_app:editable(Event) of
        false -> {p, [], ?T("Please login.")};

        true ->
            Id = Event#event.id,
            Tags = m_tag:all(event, Id),
            p_event_form:render(put, ale:path(update, [Id]), Event, Tags)
    end.
