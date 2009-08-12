-module(p_qa_form).

-compile(export_all).

-include("sticky.hrl").
-include("qa.hrl").

render(Method, Action, Qa, Tags) ->
    Js = ale:ff("p_qa_form.js"),
    ale:app_add_js(Js),

    {Question, EncryptedAnswer} = ale:mathcha(),
    Cancel = case Method of
        put -> [{a, [{href, ale:path(qa, show, [Qa#qa.id])}], ?T("Cancel")}, " "];
        _   -> ""
    end,
    {form, [{id, qa_form}, {method, post}, {action, Action}], [
        {input, [{type, hidden}, {name, "_method"}, {value, Method}]},

        {span, [{class, label}], ?T("Question")},
        {input, [{type, text}, {class, textbox}, {name, question}, {value, Qa#qa.question}]},

        {span, [{class, label}], ?T("Detail")},
        {textarea, [{name, detail}], Qa#qa.detail},

        h_tag:render_tag_selection(Tags),

        {span, [{class, label}], Question},
        {input, [{type, text}, {class, textbox}, {name, answer}]},
        {input, [{type, hidden}, {name, encrypted_answer}, {value, EncryptedAnswer}]},

        Cancel, {input, [{type, submit}, {class, button}, {value, ?T("Save")}]}
    ]}.
