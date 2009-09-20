-module(h_event).

-compile(export_all).

-include("sticky.hrl").
-include("event.hrl").

render_name() -> yaws_api:htmlize(?T("Event")).

render_title(Event) -> yaws_api:htmlize(Event#event.name).

render_preview(Event) ->
    User = m_user:find(Event#event.user_id),
    [
        render_header(User, Event),
        {'div', [], Event#event.invitation}
    ].

render_header(User, Event) ->
    Views = case Event#event.views > 1 of
        true  -> ?TF("~p views", [Event#event.views]);
        false -> undefined
    end,
    Edit = case h_app:editable(Event) of
        true  -> {a, [{href, ale:path(event, edit, [Event#event.id])}], ?T("Edit")};
        false -> undefined
    end,
    [
        h_user:render(User, [
            h_tag:render_tags(event, Event#event.id),
            h_app:render_timestamp(Event#event.created_at, Event#event.updated_at),
            Views,
            Edit
        ])
    ].
