-module(p_article_detail).

-compile(export_all).

-include("sticky.hrl").

render(Content) ->
    {Abstract, Body} = Content#content.data,
    {'div', [], [Abstract, Body]}.
