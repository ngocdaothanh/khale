-module(p_qa_preview).

-compile(export_all).

-include("sticky.hrl").
-include("qa.hrl").

render(Content) ->
    Data = Content#content.data,
    {'div', [], Data#qa.context}.
