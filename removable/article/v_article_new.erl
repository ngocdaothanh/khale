-module(v_article_new).

-compile(export_all).

-include("sticky.hrl").

render() ->
    Title = ?T("Create new article"),
    ale:app(title_in_head, Title),
    ale:app(title_in_body, Title),

    {Question, EncryptedAnswer} = ale:mathcha(),
    [
        {p, [], ?T("You can create content of type article to post a notice, a tutorial etc.")},

        {form, [{method, post}, {action, ale:path(create)}], [
            {span, [{class, label}], ?T("Title")},
            {input, [{type, text}, {class, textbox}, {name, title}]},

            {span, [{class, label}], ?T("Abstract")},
            {textarea, [{name, abstract}]},

            {span, [{class, label}], ?T("Body")},
            {textarea, [{name, body}]},

            h_tag:render_tag_selection(),

            {span, [{class, label}], Question},
            {input, [{type, text}, {class, textbox}, {name, answer}]},
            {input, [{type, hidden}, {name, encrypted_answer}, {value, EncryptedAnswer}]},

            {input, [{type, submit}, {class, button}, {value, ?T("Save")}]}
        ]}
    ].
