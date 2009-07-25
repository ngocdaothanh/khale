-module(h_event).

-compile(export_all).

-include("sticky.hrl").
-include("event.hrl").

name() -> yaws_api:htmlize(?T("Event")).

title(Content) ->
    Data = Content#content.data,
    yaws_api:htmlize(Data#event.name).
