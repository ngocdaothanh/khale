-module(h_poll).

-compile(export_all).

-include("sticky.hrl").
-include("poll.hrl").

name() -> yaws_api:htmlize(?T("Poll")).

title(Content) ->
    Data = Content#content.data,
    yaws_api:htmlize(Data#poll.question).
