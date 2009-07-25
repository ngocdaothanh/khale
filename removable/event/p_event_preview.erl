-module(p_event_preview).

-compile(export_all).

-include("sticky.hrl").
-include("event.hrl").

render(Content) ->
    Data = Content#content.data,
    {'div', [], Data#event.invitation}.
