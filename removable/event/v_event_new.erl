-module(v_event_new).

-compile(export_all).

-include("sticky.hrl").

render() ->
    Title = ?T("Create new event"),
    ale:app(title_in_head, Title),
    ale:app(title_in_body, Title),
    [
        {p, [], ?T("You can create content of type event to invite people to participate in an event such as a party, AND you want to create a list of participants so that you know the exact number.")},

        {span, [{class, label}], ?T("Title")},
        {input, [{type, text}, {name, title}]}
    ].
