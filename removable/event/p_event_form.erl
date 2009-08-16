-module(p_event_form).

-compile(export_all).

-include("sticky.hrl").
-include("event.hrl").

render(Method, Action, Event, Tags) ->
    Js = ale:ff("p_event_form.js"),
    ale:app_add_js(Js),

    Cancel = case Method of
        put -> [{a, [{href, ale:path(event, show, [Event#event.id])}], ?T("Cancel")}, " "];
        _   -> ""
    end,
    {form, [{id, event_form}, {method, post}, {action, Action}], [
        {input, [{type, hidden}, {name, "_method"}, {value, Method}]},

        {span, [{class, label}], ?T("Name")},
        {input, [{type, text}, {class, textbox}, {name, name}, {value, Event#event.name}]},

        {span, [{class, label}], ?T("Invitation")},
        {textarea, [{name, invitation}], Event#event.invitation},

        {span, [{class, label}], ?T("Registration deadline")},
        {input, [{type, text}, {class, "textbox quarter date_picker"}, {name, deadline_on}, {value, h_application:render_date(Event#event.deadline_on)}]},

        h_tag:render_tag_selection(Tags),

        h_application:render_mathcha(),

        {input, [{type, submit}, {class, button}, {value, ?T("Save")}]}, " ", Cancel
    ]}.
