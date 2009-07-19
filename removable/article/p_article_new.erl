-module(p_article_new).

-compile(export_all).

-include("sticky.hrl").

render() ->
    ale:app(title, ?T("Create new article")),
    [
        {p, [], ?T("You can create content of type article to post a notice, a tutorial etc. You can allow everyone to freely edit to improve it.")},

        {span, [{class, label}], ?T("Title")},
        {input, [{type, text}, {name, title}]},

        {span, [{class, label}], ?T("Abstract")},
        {textarea, [{name, abstract}]},

        {span, [{class, label}], ?T("Body")},
        {textarea, [{name, body}]}
    ].
