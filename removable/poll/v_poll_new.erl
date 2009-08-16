-module(v_poll_new).

-compile(export_all).

-include("sticky.hrl").
-include("poll.hrl").

render() ->
    Title = ?T("Create new poll"),
    ale:app(title_in_head, Title),
    ale:app(title_in_body, Title),

    Js = ale:ff("p_poll_form.js"),
    ale:app_add_js(Js),

    {form, [{id, poll_form}, {method, post}, {action, ale:path(create)}], [
        {span, [{class, label}], ?T("Question")},
        {input, [{type, text}, {class, textbox}, {name, question}]},

        {span, [{class, label}], ?T("Choices (empty ones will be ignored)")},
        {ol, [], [
            {li, [], {input, [{type, text}, {class, textbox}, {name, "choices[]"}]}},
            {li, [], {input, [{type, text}, {class, textbox}, {name, "choices[]"}]}},
            {li, [], {input, [{type, text}, {class, textbox}, {name, "choices[]"}]}}
        ]},
        {input, [{type, button}, {class, button}, {value, ?T("Add")}]},

        {span, [{class, label}], ?T("Poll deadline (empty means forever)")},
        {input, [{type, text}, {class, "textbox quarter date_picker"}, {name, deadline_on}]},

        h_tag:render_tag_selection([]),

        h_application:render_mathcha(),

        {input, [{type, submit}, {class, button}, {value, ?T("Save")}]},
        [" (", ?T("Please be careful because you cannot edit this poll once it is created."), ")"]
    ]}.
