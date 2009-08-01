-module(v_article_new).

-compile(export_all).

-include("sticky.hrl").

render() ->
    Title = ?T("Create new article"),
    ale:app(title_in_head, Title),
    ale:app(title_in_body, Title),
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
