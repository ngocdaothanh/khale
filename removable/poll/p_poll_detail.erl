-module(p_poll_detail).

-compile(export_all).

-include("sticky.hrl").

render(Content) ->
    {AbstractAndQuestion, Selections, Votes} = Content#content.data,
    {'div', [], [
        AbstractAndQuestion
    ]}.
