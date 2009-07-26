-module(h_poll).

-compile(export_all).

-include("sticky.hrl").
-include("poll.hrl").

render_name() -> yaws_api:htmlize(?T("Poll")).

render_title(Poll) -> yaws_api:htmlize(Poll#poll.question).
