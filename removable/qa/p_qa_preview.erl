-module(p_qa_preview).

-compile(export_all).

-include("sticky.hrl").

render(Content) ->
    AbstractAndQuestion = Content#content.data,
    {'div', [], AbstractAndQuestion}.
