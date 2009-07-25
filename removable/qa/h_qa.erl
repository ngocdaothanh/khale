-module(h_qa).

-compile(export_all).

-include("sticky.hrl").
-include("qa.hrl").

name() -> yaws_api:htmlize(?T("Q/A")).

title(Content) ->
    Data = Content#content.data,
    yaws_api:htmlize(Data#qa.question).
