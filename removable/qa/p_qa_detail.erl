-module(p_qa_detail).

-compile(export_all).

-include("sticky.hrl").

render(Content) -> p_qa_preview:render(Content).
