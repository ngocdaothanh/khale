-module(p_article_form).

-compile(export_all).

-include("sticky.hrl").
-include("article.hrl").

render(Method, Action, Article, Tags) ->
    Js = ale:ff("p_article_form.js"),
    ale:app_add_js(Js),

    Cancel = case Method of
        put -> [{a, [{href, ale:path(article, show, [Article#article.id])}], ?T("Cancel")}, " "];
        _   -> ""
    end,
    {form, [{id, article_form}, {method, post}, {action, Action}], [
        {input, [{type, hidden}, {name, "_method"}, {value, Method}]},

        {span, [{class, label}], ?T("Title")},
        {input, [{type, text}, {class, textbox}, {name, title}, {value, Article#article.title}]},

        {span, [{class, label}], ?T("Abstract")},
        {textarea, [{name, abstract}], Article#article.abstract},

        {span, [{class, label}], ?T("Body")},
        {textarea, [{name, body}], Article#article.body},

        h_tag:render_tag_selection(Tags),

        h_application:render_mathcha(),

        {input, [{type, submit}, {class, button}, {value, ?T("Save")}]}, " ", Cancel
    ]}.
