-module(p_qa_detail).

-compile(export_all).

-include("sticky.hrl").

render(Content) ->
    AbstractAndQuestion = Content#content.data,
    {'div', [], AbstractAndQuestion}.
