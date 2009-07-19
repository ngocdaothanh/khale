-module(p_event_new).

-compile(export_all).

-include("sticky.hrl").

render() ->
    ale:app(title, ?T("Create new event")),
    [
        {p, [], ?T("You can create content of type event to invite people to participate in an event such as a party, AND you want to create a list of participants so that you know the exact number.")},

        {span, [{class, label}], ?T("Title")},
        {input, [{type, text}, {name, title}]}
    ].
