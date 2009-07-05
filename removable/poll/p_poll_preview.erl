-module(p_poll_preview).

-compile(export_all).

-include("sticky.hrl").

render(Content) ->
    {AbstractAndQuestion, Selections, Votes} = Content#content.data,
    {'div', [], AbstractAndQuestion}.
