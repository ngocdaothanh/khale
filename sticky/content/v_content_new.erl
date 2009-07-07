-module(v_content_new).

-compile(export_all).

-include_lib("sticky.hrl").

render() ->
    PartialNew = ale:app(partial_new),
    [
        {form, [{method, post}, {action, ["/new/", ale:app(type)]}], [
            PartialNew:render(),
            {input, [{type, hidden}, {name, "_method"}, {value, post}]},
            {input, [{type, submit}, {value, ?T("Save")}]}
        ]}
    ].
