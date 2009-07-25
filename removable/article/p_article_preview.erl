-module(p_article_preview).

-compile(export_all).

-include("sticky.hrl").
-include("article.hrl").

render(Content) ->
    Data = Content#content.data,
    {'div', [], Data#article.abstract}.
