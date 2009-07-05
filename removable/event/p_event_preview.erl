-module(p_event_preview).

-compile(export_all).

-include("sticky.hrl").

render(Content) ->
    {Invitation, _DeadLine, _Participants} = Content#content.data,
    {'div', [], Invitation}.
