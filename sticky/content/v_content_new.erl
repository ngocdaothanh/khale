-module(v_content_new).

-compile(export_all).

-include_lib("sticky.hrl").

render() ->
    Type = ale:get(app, type),
    PartialNew = ale:get(app, partial_new),
    [
        {form, [{method, post}, {action, ["/new/", Type]}], [
            PartialNew:render(),
            {input, [{type, hidden}, {name, "_method"}, {value, post}]},
            {input, [{type, submit}, {value, ?T("Save")}]}
        ]}
    ].
