-module(p_article_preview).

-compile(export_all).

-include("sticky.hrl").

render(Content) ->
    {Abstract, _Body} = Content#content.data,
    {'div', [], Abstract}.
