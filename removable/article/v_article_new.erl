-module(v_article_new).

-compile(export_all).

-include("sticky.hrl").

render() ->
    [
        {span, [{class, "label"}], ?T("Title")},
        {input, [{type, "text"}, {name, "title"}]},

        {span, [{class, "label"}], ?T("Abstract")},
        {input, [{type, "text"}, {name, "abstract"}]},

        {span, [{class, "label"}], ?T("Body")},
        {textarea, [{name, "body"}]}
    ].
