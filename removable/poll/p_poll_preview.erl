-module(p_poll_preview).

-compile(export_all).

-include("sticky.hrl").
-include("poll.hrl").

render(Content) ->
    Data = Content#content.data,
    {'div', [], Data#poll.context}.
