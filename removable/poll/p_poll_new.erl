-module(p_poll_new).

-compile(export_all).

-include("sticky.hrl").

render() ->
    ale:app(title, ?T("Create new poll")),
    [
        {span, [{class, label}], ?T("Title")},
        {input, [{type, text}, {name, title}]}
    ].
