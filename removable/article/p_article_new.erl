-module(p_article_new).

-compile(export_all).

-include("sticky.hrl").

render() ->
    ale:put(app, title, ?T("Create new article")),
    [
        {span, [{class, label}], ?T("Title")},
        {input, [{type, text}, {name, title}]},

        {span, [{class, label}], ?T("Abstract")},
        {textarea, [{name, abstract}]},

        {span, [{class, label}], ?T("Body")},
        {textarea, [{name, body}]}
    ].
