-module(v_article_new).

-compile(export_all).

-include("sticky.hrl").

render() ->
    ale:app(title, ?T("Create new article")),
    [
        {p, [], ?T("You can create content of type article to post a notice, a tutorial etc.")},

        {form, [{method, post}, {action, ale:path(content, create, [ale:params(content_type)])}], [
            {span, [{class, label}], ?T("Title")},
            {input, [{type, text}, {name, title}]},

            {span, [{class, label}], ?T("Abstract")},
            {textarea, [{name, abstract}]},

            {span, [{class, label}], ?T("Body")},
            {textarea, [{name, body}]},

            {input, [{type, submit}, {value, ?T("Save")}]}
        ]}
    ].
