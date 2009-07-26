-module(h_event).

-compile(export_all).

-include("sticky.hrl").
-include("event.hrl").

render_name() -> yaws_api:htmlize(?T("Event")).

render_title(Event) -> yaws_api:htmlize(Event#event.name).
