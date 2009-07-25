-module(h_article).

-compile(export_all).

-include("sticky.hrl").
-include("article.hrl").

name() -> yaws_api:htmlize(?T("Article")).

title(Content) ->
    Data = Content#content.data,
    yaws_api:htmlize(Data#article.title).
